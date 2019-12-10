Pod::Spec.new do |s|

  s.name         = "ikaSDK"
  s.version 	 = '1.0.0'
  s.license      = { :type => 'PROPRIETARY', :file => 'LICENSE' }
  s.authors      = { 'Ilija Stevanovic PR ikaS Beograd' => 'ikas92@gmail.com' }
  s.summary      = ""
  s.source 	 = { :git => "https://github.com/istevanovic/ikaSDK", :tag => s.version.to_s }

  base_dir = 'ikaSDK/ikaSDK'
  s.source_files = base_dir + '/**/*.{h,m,swift}'
  s.public_header_files = base_dir + '/**/*.h'

  s.platform = :ios, '10.0'
  s.frameworks = 'SystemConfiguration'
  s.static_framework = true

  s.dependency 'Firebase/Analytics'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Database'
  s.dependency 'PromisesSwift'

end
