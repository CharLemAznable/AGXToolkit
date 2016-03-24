Pod::Spec.new do |s|
  s.name                = "AGXToolkit"
  s.version             = "0.0.16"
  s.summary             = "Personal Toolkit."
  s.description         = "个人日常开发工具代码.\n\n  - AGXCore: 核心依赖包\n  - AGXRuntime: 运行时工具包\n  - AGXJson: JSON工具包\n  - AGXLayout: 视图自动布局\n  - AGXData: 本地数据存取工具包\n  - AGXWidget: 页面组件工具包"
  s.homepage            = "https://github.com/CharLemAznable/AGXToolkit"
  s.license             = { :type => 'MIT', :file => 'AGXToolkit/LICENSE' }
  s.author              = "CharLemAznable"
  s.platform            = :ios, '5.0'
  s.requires_arc        = false
  s.xcconfig            = { :LIBRARY_SEARCH_PATHS => "$(PODS_ROOT)/AGXToolkit" }
  s.source              = { :http => "https://raw.githubusercontent.com/CharLemAznable/AGXToolkit/master/Products/AGXToolkit-0.0.16.zip" }
  s.subspec 'AGXCore' do |c|
      c.vendored_frameworks = 'AGXToolkit/AGXCore.framework'
      c.frameworks          = 'Foundation', 'CoreGraphics', 'UIKit'
  end
  s.subspec 'AGXRuntime' do |r|
      r.vendored_frameworks = 'AGXToolkit/AGXRuntime.framework'
      r.dependency            'AGXToolkit/AGXCore'
  end
  s.subspec 'AGXJson' do |j|
      j.vendored_frameworks = 'AGXToolkit/AGXJson.framework'
      j.dependency            'AGXToolkit/AGXRuntime'
  end
  s.subspec 'AGXLayout' do |l|
      l.vendored_frameworks = 'AGXToolkit/AGXLayout.framework'
      l.dependency            'AGXToolkit/AGXCore'
  end
  s.subspec 'AGXData' do |d|
      d.vendored_frameworks = 'AGXToolkit/AGXData.framework'
      d.dependency            'AGXToolkit/AGXJson'
      d.frameworks          = 'Security'
  end
  s.subspec 'AGXWidget' do |w|
      w.vendored_frameworks = 'AGXToolkit/AGXWidget.framework'
      w.dependency            'AGXToolkit/AGXRuntime'
      w.frameworks          = 'CoreText'
  end
end
