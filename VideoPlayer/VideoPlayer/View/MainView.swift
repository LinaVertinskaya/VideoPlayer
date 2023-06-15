//
//  MainView.swift
//  VideoPlayer
//
//  Created by Лина Вертинская on 13.06.23.
//

import SwiftUI
import AVKit

struct MainView: View {

    var size: CGSize
    var safeArea: EdgeInsets

    @State private var player: AVPlayer? = {
        guard let path = Bundle.main.path(forResource: "English", ofType: "mp4") else { return nil }
        return AVPlayer(url: URL(filePath: path))
    }()

    @State private var showControls = false
    @State private var isPlaying = false
    @State private var timeoutTask: DispatchWorkItem?

    // Свойства слайдера
    @State private var isSeeking = false
    @State private var isFinishedVideo = false
    @State private var progress: CGFloat = 0.3
    @State private var lastProgress: CGFloat = 0.0
    @GestureState private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            let playerSize = CGSize(width: size.width,
                                    height: size.height / 3.4)

            ZStack {
                if let player {
                    VideoPlayer(player: player)
                        .overlay {
                            Rectangle()
                                .fill(.black.opacity(0.4))
                                .opacity(showControls ? 1 : 0)
                                .overlay {
                                    if showControls {
                                        playControls()
                                    }
                                }
                        }
                        .onTapGesture {
                            withAnimation {
                                showControls.toggle()
                            }
                        }
                        .overlay(alignment: .bottom) {
                            sliderView(videoSize: playerSize)
                        }
                }
            }.frame(width: playerSize.width,
                    height: playerSize.height)

            ScrollView { }
        }
        .padding(.top, safeArea.top)
        .onAppear {
            player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 1),
                                            queue: .main) { time in
                if let currentVideo = player?.currentItem {
                    let totalDuration = currentVideo.duration.seconds
                    guard let currentDuration = player?.currentTime().seconds else { return }
                    let currentProgress = currentDuration / totalDuration
                    if !isSeeking {
                        progress = currentProgress
                        lastProgress = progress
                    }
                    if currentProgress == 1 {
                        isFinishedVideo = true
                        isPlaying = false
                    }
                }
            }
        }
    }

    @ViewBuilder func playControls() -> some View {
        HStack(spacing: 40) {
            Button {
                print("Backward")
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .padding()
                    .background {
                        Circle()
                            .fill(.black.opacity(0.4))
                    }
            }.disabled(true)
                .opacity(0.6)

            Button {
                switch isPlaying {
                case true:
                    player?.pause()
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                case false:
                    player?.play()
                    timeoutControls()
                }
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .padding(20)
                    .background {
                        Circle()
                            .fill(.black.opacity(0.4))
                    }
            }

            Button {
                print("Forward")
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .padding()
                    .background {
                        Circle()
                            .fill(.black.opacity(0.4))
                    }
            }.disabled(true)
                .opacity(0.6)
        }
    }

    func timeoutControls() {
        if let timeoutTask {
            timeoutTask.cancel()
        }
        timeoutTask = DispatchWorkItem {
            withAnimation {
                showControls = false
            }
        }

        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3,
                                          execute: timeoutTask)
        }
    }

    @ViewBuilder func sliderView(videoSize: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.gray)
            Rectangle()
                .fill(.red)
                .frame(width: videoSize.width * progress)
        }.frame(height: 3)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.red)
                    .frame(width: 16, height: 16)
                    .scaleEffect(showControls || isDragging ? 1 : 0)
                    .frame(width: 50, height: 50)
                    .contentShape(Rectangle())
                    .offset(x: size.width * progress - 25)
                    .gesture(
                        DragGesture()
                            .updating($isDragging) { _, out, _ in
                                          out = true
                                      }
                            .onChanged { value in
                                if let timeoutTask {
                                    timeoutTask.cancel()
                                }
                                let dx = value.translation.width
                                let newProgress = dx / videoSize.width + lastProgress
                                self.progress = newProgress

                                isSeeking = true
                            }
                            .onEnded { value in
                                lastProgress = progress
                                if let currentVideo = player?.currentItem {
                                    let totalDuration = currentVideo.duration.seconds
                                    player?.seek(to: CMTime(seconds: totalDuration * progress, preferredTimescale: 1))
                                }
                                if isPlaying {
                                    timeoutControls()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isSeeking = false
                                }
                            }
                    )
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
