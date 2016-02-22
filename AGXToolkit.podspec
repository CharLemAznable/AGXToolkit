Pod::Spec.new do |s|
  s.name                = "AGXToolkit"
  s.version             = "0.0.7"
  s.summary             = "Personal Toolkit."
  s.description         = <<-DESC
                            个人日常开发工具代码.
                            - AGXCore: 核心依赖包
                            - AGXRuntime: 运行时工具包
                            - AGXJson: JSON工具包
                            - AGXHUD: ProgressHUD工具包
                            - AGXLayout: 视图自动布局
                            - AGXData: 本地数据存取工具包
                          DESC
  s.homepage            = "https://github.com/CharLemAznable/AGXToolkit"
  s.license             = { :type => 'MIT',
                            :text => <<-LICENSE
                                        Copyright (c) 2016 CharLemAznable

                                        Permission is hereby granted, free of charge, to any person obtaining a copy
                                        of this software and associated documentation files (the "Software"), to deal
                                        in the Software without restriction, including without limitation the rights
                                        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                                        copies of the Software, and to permit persons to whom the Software is
                                        furnished to do so, subject to the following conditions:

                                        The above copyright notice and this permission notice shall be included in all
                                        copies or substantial portions of the Software.

                                        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                                        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                                        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                                        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                                        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                                        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                                        SOFTWARE.
                                     LICENSE
                          }
  s.author              = "CharLemAznable"
  s.platform            = :ios, '5.0'
  s.requires_arc        = false
  s.frameworks          = 'Foundation', 'CoreGraphics', 'UIKit'
  s.xcconfig            = { :LIBRARY_SEARCH_PATHS => "$(PODS_ROOT)/AGXToolkit" }
  s.source              = { :http => "https://raw.githubusercontent.com/CharLemAznable/AGXToolkit/master/Products/AGXToolkit.zip" }
  s.subspec 'AGXCore' do |c|
      c.vendored_frameworks = 'AGXToolkit/AGXCore.framework'
  end
  s.subspec 'AGXRuntime' do |r|
      r.vendored_frameworks = 'AGXToolkit/AGXRuntime.framework'
      r.dependency            'AGXToolkit/AGXCore'
  end
  s.subspec 'AGXJson' do |j|
      j.vendored_frameworks = 'AGXToolkit/AGXJson.framework'
      j.dependency            'AGXToolkit/AGXRuntime'
  end
  s.subspec 'AGXHUD' do |h|
      h.vendored_frameworks = 'AGXToolkit/AGXHUD.framework'
      h.dependency            'AGXToolkit/AGXCore'
  end
  s.subspec 'AGXLayout' do |l|
      l.vendored_frameworks = 'AGXToolkit/AGXLayout.framework'
      l.dependency            'AGXToolkit/AGXCore'
  end
  s.subspec 'AGXData' do |d|
      d.vendored_frameworks = 'AGXToolkit/AGXData.framework'
      d.dependency            'AGXToolkit/AGXJson'
  end
end
