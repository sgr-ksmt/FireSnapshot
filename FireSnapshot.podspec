Pod::Spec.new do |s|
  s.name             = "FireSnapshot"
  s.version          = "0.4.0"
  s.summary          = "Firebase Cloud Firestore Model Framework using Codable."
  s.homepage         = "https://github.com/sgr-ksmt/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Suguru Kishimoto" => "melodydance.k.s@gmail.com" }
  s.source           = { :git => "#{s.homepage}.git", :tag => s.version.to_s }
  s.platform         = :ios, '11.0'
  s.requires_arc     = true
  s.source_files     = "FireSnapshot/Sources/**/*.swift"
  s.static_framework = true
  s.swift_version    = "5.1"
  s.dependency "Firebase/Firestore", "~> 6.9"
end
