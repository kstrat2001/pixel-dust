Pod::Spec.new do |spec|
  spec.name         = 'PixelDust'
  spec.version      = '0.1.4'
  spec.summary      = 'PixelDust GPU image processing library'

  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'

  spec.source       = { git: 'git@github.com:kstrat2001/pixel-dust.git', tag: "#{spec.version}" }
  spec.author       = { 'Kain Osterholt' => 'kain.osterholt@gmail.com' }
  spec.license      = { type: 'MIT' }
  spec.homepage     = 'kainosterholt.com'
  spec.swift_version = "4.2"

  spec.source_files = 'ImageComparator/*.{h,m}'
  spec.resources    = 'ImageComparator/Shaders/*.{frg,vtx}'
end
