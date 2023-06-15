//
//  VideoPlayer.swift
//  VideoPlayer
//
//  Created by Лина Вертинская on 13.06.23.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
