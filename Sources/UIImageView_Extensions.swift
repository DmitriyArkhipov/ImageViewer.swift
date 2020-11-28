import UIKit

extension UIImageView {
    public typealias OnTapCallback = () -> Void
    
    // Data holder tap recognizer
    private class TapWithDataRecognizer: UITapGestureRecognizer {
        weak var from:UIViewController?
        var imageDatasource:ImageDataSource?
        var initialIndex:Int = 0
        var options:[ImageViewerOption] = []
        var onTap: OnTapCallback?
    }
    
    private var vc: UIViewController? {
        let getRootVC = { () -> UIViewController? in
            if #available(iOS 13.0, *) {
                return UIApplication.shared.windows.first?.rootViewController
            } else {
                return UIApplication.shared.keyWindow?.rootViewController
            }
        }
        
        guard let rootVC = getRootVC() else {
            return nil
        }

        return rootVC.presentedViewController != nil ? rootVC.presentedViewController : rootVC
    }
    
    public func setupImageViewer(
        options:[ImageViewerOption] = [],
        from: UIViewController? = nil
    ) {
        setup(
            datasource: SimpleImageDatasource(imageItems: [.image(image)]),
            options: options,
            from: from
        )
    }
    
    #if canImport(SDWebImage)
    public func setupImageViewer(
        url:URL,
        initialIndex: Int = 0,
        placeholder: UIImage? = nil,
        options: [ImageViewerOption] = [],
        from: UIViewController? = nil,
        onTap: OnTapCallback? = nil
    ) {
        
        let datasource = SimpleImageDatasource(
            imageItems: [url].compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            onTap: onTap
        )
    }
    #endif
    
    public func setupImageViewer(
        images: [UIImage],
        initialIndex: Int = 0,
        options: [ImageViewerOption] = [],
        from:UIViewController? = nil,
        onTap: OnTapCallback? = nil
    ) {
        
        let datasource = SimpleImageDatasource(
            imageItems: images.compactMap {
                ImageItem.image($0)
        })
        
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            onTap: onTap
        )
    }
    
    #if canImport(SDWebImage)
    public func setupImageViewer(
        urls: [URL],
        initialIndex: Int = 0,
        options: [ImageViewerOption] = [],
        placeholder: UIImage? = nil,
        from: UIViewController? = nil,
        onTap: OnTapCallback? = nil
    ) {
        
        let datasource = SimpleImageDatasource(
            imageItems: urls.compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            onTap: onTap
        )
    }
    #endif
    
    public func setupImageViewer(
        datasource: ImageDataSource,
        initialIndex: Int = 0,
        options: [ImageViewerOption] = [],
        from: UIViewController? = nil,
        onTap: OnTapCallback? = nil
    ) {
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            onTap: onTap
        )
    }
    
    private func setup(
        datasource: ImageDataSource?,
        initialIndex: Int = 0,
        options: [ImageViewerOption] = [],
        from: UIViewController? = nil,
        onTap: OnTapCallback? = nil
    ) {
        
        var _tapRecognizer:TapWithDataRecognizer?
        
        gestureRecognizers?.forEach {
            if let _tr = $0 as? TapWithDataRecognizer {
                // if found, just use existing
                _tapRecognizer = _tr
            }
        }
        
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        // Pass the Data
        _tapRecognizer!.imageDatasource = datasource
        _tapRecognizer!.initialIndex = initialIndex
        _tapRecognizer!.options = options
        _tapRecognizer!.from = from
        _tapRecognizer!.onTap = onTap
        
        addGestureRecognizer(_tapRecognizer!)
    }
    
    @objc
    private func showImageViewer(_ sender: TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else {
            return
        }
        
        sender.onTap?()
        
        let imageCarousel = ImageCarouselViewController.init(
            sourceView: sourceView,
            imageDataSource: sender.imageDatasource,
            options: sender.options,
            initialIndex: sender.initialIndex
        )
        
        let presentFromVC = sender.from ?? vc

        presentFromVC?.present(imageCarousel, animated: true)
    }
}
