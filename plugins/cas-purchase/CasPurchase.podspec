Pod::Spec.new do |s|
  s.name = 'CasPurchase'
  s.version = '1.0.0'
  s.summary = 'StoreKit 2 one-off purchase for CAS OBD Scanner Pro'
  s.license = 'UNLICENSED'
  s.homepage = 'https://github.com/stirlingcraig-cyber'
  s.author = 'CAS Solutions'
  s.source = { :git => '', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m}'
  s.ios.deployment_target = '15.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
end
