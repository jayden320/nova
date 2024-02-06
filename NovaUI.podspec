Pod::Spec.new do |s|
  s.name             = 'NovaUI'
  s.version          = '0.1.0'
  s.summary          = 'APM SDK'
  s.description      = <<-DESC
iOS performance monitoring tool designed to empower developers with comprehensive insights into their apps' performance.
                       DESC

  s.homepage         = 'https://github.com/jayden320/nova'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jayden Liu' => 'jaydenliu320@gmail.com' }
  s.source           = { :git => 'https://github.com/jayden320/nova.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
  s.static_framework = true

  s.dependency 'NovaMetrics/Core'
  s.source_files = 'NovaUI/Classes/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'NovaUI/Tests/**/*'
    test_spec.requires_app_host = true
  end  

end
