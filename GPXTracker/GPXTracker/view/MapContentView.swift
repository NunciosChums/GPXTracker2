import MapKit
import SwiftUI

struct MapContentView: View {
  @Environment(AppState.self) private var appState

  var body: some View {
    @Bindable var appState = appState

    Map(position: $appState.cameraPosition) {
      // 경로(polyline) 표시
      ForEach(appState.mapContent.lines) { line in
        MapPolyline(coordinates: line.coordinates)
          .stroke(line.strokeColor, lineWidth: line.lineWidth)
      }

      // 시작/끝 핀 표시
      ForEach(appState.mapContent.lines) { line in
        Annotation(line.startPin.title, coordinate: line.startPin.coordinate) {
          PinMarkerView(pin: line.startPin)
            .onTapGesture { appState.selectedPin = line.startPin }
        }
        Annotation(line.endPin.title, coordinate: line.endPin.coordinate) {
          PinMarkerView(pin: line.endPin)
            .onTapGesture { appState.selectedPin = line.endPin }
        }
      }

      // 장소(place) 핀 표시
      ForEach(appState.mapContent.places) { place in
        Annotation(place.title, coordinate: place.coordinate) {
          Group {
            if place.iconUrl != nil {
              ImagePinView(pin: place)
            } else {
              PinMarkerView(pin: place)
            }
          }
          .onTapGesture { appState.selectedPin = place }
        }
      }

      UserAnnotation()
    }
    .mapStyle(appState.mapStyle)
    .onChange(of: appState.cameraPosition) {
      UIApplication.shared.isIdleTimerDisabled = appState.cameraPosition.followsUserLocation
    }
    .onTapGesture {
      if appState.selectedPin != nil {
        appState.selectedPin = nil
      }
    }
    .mapControls {
      // 시스템 내장 위치 추적 버튼 — MapKit이 직접 관리하여 배터리 절약
      MapUserLocationButton()
      MapCompass()
      MapScaleView()
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      VStack(spacing: 0) {
        // 핀 상세 카드 — 선택된 핀이 있을 때만 표시
        if let pin = appState.selectedPin {
          PinDetailCard(pin: pin, onMoveTo: {
            appState.moveToPin(pin)
          }, onDismiss: {
            appState.selectedPin = nil
          })
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        controlButtons
      }
      .animation(.easeInOut(duration: 0.25), value: appState.selectedPin?.id)
    }
    .overlay {
      if appState.isParsingFile {
        ProgressView()
          .padding(20)
          .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
      }
    }
  }

  private var controlButtons: some View {
    HStack(spacing: 8) {
      Spacer()
      if !appState.mapContent.allCoordinates.isEmpty {
        if !appState.mapContent.lines.isEmpty {
          startPinButton
          endPinButton
        }
        zoomButton
      }
      mapTypeButton
    }
    .padding(.horizontal, 12)
    .padding(.bottom, 12)
  }

  private var startPinButton: some View {
    Button {
      appState.goToNextStartPin()
    } label: {
      Image(systemName: "pin.fill")
        .foregroundStyle(.green)
        .mapControlStyle()
    }
  }

  private var endPinButton: some View {
    Button {
      appState.goToNextEndPin()
    } label: {
      Image(systemName: "pin.fill")
        .foregroundStyle(.red)
        .mapControlStyle()
    }
  }

  private var zoomButton: some View {
    Button {
      appState.zoomToFit()
    } label: {
      Image(systemName: "arrow.up.left.and.arrow.down.right")
        .mapControlStyle()
    }
  }

  private var mapTypeButton: some View {
    Button {
      appState.toggleMapStyle()
    } label: {
      Image(systemName: appState.isHybridMap ? "map.fill" : "map")
        .mapControlStyle()
    }
  }
}

// MARK: - Pin Views

struct PinMarkerView: View {
  let pin: GTPin

  var body: some View {
    Image(systemName: "mappin.circle.fill")
      .font(.title)
      .foregroundStyle(pin.color)
      .shadow(radius: 2)
  }
}

struct ImagePinView: View {
  let pin: GTPin

  var body: some View {
    if let urlString = pin.iconUrl, let url = URL(string: urlString) {
      AsyncImage(url: url) { image in
        image.resizable().scaledToFit()
      } placeholder: {
        Image(systemName: "mappin.circle.fill")
          .foregroundStyle(pin.color)
      }
      .frame(width: 32, height: 32)
    }
  }
}

// MARK: - Pin Detail Card (overlay, Apple Maps 스타일)

struct PinDetailCard: View {
  let pin: GTPin
  let onMoveTo: () -> Void
  let onDismiss: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // 첫째 줄: 핀 아이콘 + 타이틀
      HStack(alignment: .center, spacing: 8) {
        if let urlString = pin.iconUrl, let url = URL(string: urlString) {
          AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
          } placeholder: {
            Image(systemName: "mappin.circle.fill")
              .font(.title2)
              .foregroundStyle(pin.color)
          }
          .frame(width: 28, height: 28)
        } else {
          Image(systemName: "mappin.circle.fill")
            .font(.title2)
            .foregroundStyle(pin.color)
        }

        Text(pin.title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity, alignment: .leading)

        Button(action: onDismiss) {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
      }

      // 둘째 줄: 위치 이동 + 네비게이션 버튼들
      HStack(spacing: 8) {
        // 해당 핀 위치로 줌 이동
        Button(action: onMoveTo) {
          Image(systemName: "scope")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(.gray, in: Circle())
        }
        Spacer()
        NavigateButton(pin: pin, mode: MKLaunchOptionsDirectionsModeDriving,
                       icon: "car.fill", color: .blue, onDismiss: onDismiss)
        NavigateButton(pin: pin, mode: MKLaunchOptionsDirectionsModeWalking,
                       icon: "figure.walk", color: .green, onDismiss: onDismiss)
        NavigateButton(pin: pin, mode: MKLaunchOptionsDirectionsModeCycling,
                       icon: "bicycle", color: .orange, onDismiss: onDismiss)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    // portrait 기준 너비 고정 — landscape에서 과도하게 넓어지는 것 방지
    .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 24)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
    .padding(.bottom, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, 12)
  }
}

// MARK: - Navigate Button

private struct NavigateButton: View {
  let pin: GTPin
  let mode: String
  let icon: String
  let color: Color
  let onDismiss: () -> Void

  var body: some View {
    Button {
      let placemark = MKPlacemark(coordinate: pin.coordinate)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = pin.title
      mapItem.openInMaps(launchOptions: [
        MKLaunchOptionsDirectionsModeKey: mode
      ])
      onDismiss()
    } label: {
      Image(systemName: icon)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(.white)
        .frame(width: 36, height: 36)
        .background(color, in: Circle())
    }
  }
}

// MARK: - Button Style

extension View {
  func mapControlStyle() -> some View {
    self
      .font(.system(size: 18, weight: .medium))
      .frame(width: 44, height: 44)
      .background(.ultraThinMaterial, in: Circle())
  }
}
