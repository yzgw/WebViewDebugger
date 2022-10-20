//
//  MovieWriter.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/26.
//

import UIKit
import AVFoundation
import CoreImage

class ScreenRecorder {

    var assetwriter: AVAssetWriter

    var assetWriterInput: AVAssetWriterInput

    var assetWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor

    var startTime: Date?

    var endTime: CMTime?

    init(outputMovieURL: URL) {
        assetwriter = try! AVAssetWriter(outputURL: outputMovieURL, fileType: .mov)
        let settingsAssistant = AVOutputSettingsAssistant(preset: .preset1280x720)?.videoSettings
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        assetWriterInput.expectsMediaDataInRealTime = true
        assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        assetwriter.add(assetWriterInput)
    }

    func start() {
        assetwriter.startWriting()
        assetwriter.startSession(atSourceTime: CMTime.zero)
        startTime = Date()
    }

    func append(image: UIImage) {
        var pixelBuffer = toPixelBuffer(image: image)
        if assetWriterInput.isReadyForMoreMediaData {
            let timePassed = -startTime!.timeIntervalSinceNow
            let frameTime = CMTimeMake(value: Int64(timePassed * 1000), timescale: 1000)
            endTime = frameTime
            assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
        }
        pixelBuffer = nil
    }

    func finish(callback: @escaping () -> Void) {
        assetWriterInput.markAsFinished()
        assetwriter.endSession(atSourceTime: endTime!)
        assetwriter.finishWriting(completionHandler: callback)
    }

    func getOutputUrl() -> URL {
        return assetwriter.outputURL
    }

    func toPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        guard let staticImage = CIImage(image: image) else {
            return nil
        }
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let width:Int = Int(staticImage.extent.size.width)
        let height:Int = Int(staticImage.extent.size.height)
        CVPixelBufferCreate(kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )
        let context = CIContext()
        context.render(staticImage, to: pixelBuffer!)
        return pixelBuffer
    }
}
