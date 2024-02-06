Pod::Spec.new do |s|
  s.name             = 'NovaMetrics'
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
  s.default_subspecs = 'Core', 'MemoryLeaksPlugin', 'AnrMonitorPlugin', 'UIThreadMonitorPlugin', 'PageMonitorPlugin'

  s.subspec 'Core' do |sp|
    sp.source_files = 'NovaMetrics/Core/Classes/**/*'
  end

  s.subspec 'MemoryLeaksPlugin' do |sp|
    sp.dependency 'NovaMetrics/MLeaksFinder'
    sp.dependency 'NovaMetrics/Core'
    sp.source_files = 'NovaMetrics/MemoryLeaksPlugin/Classes/**/*'
  end

  s.subspec 'AnrMonitorPlugin' do |sp|
    sp.dependency 'NovaMetrics/Core'
    sp.source_files = 'NovaMetrics/AnrMonitorPlugin/Classes/**/*'
  end

  s.subspec 'UIThreadMonitorPlugin' do |sp|
    sp.dependency 'NovaMetrics/Core'
    sp.source_files = 'NovaMetrics/UIThreadMonitorPlugin/Classes/**/*'
  end

  s.subspec 'PageMonitorPlugin' do |sp|
    sp.dependency 'NovaMetrics/Core'
    sp.dependency 'NovaMetrics/VCProfiler'
    sp.source_files = 'NovaMetrics/PageMonitorPlugin/Classes/**/*'
  end

  s.subspec 'MLeaksFinder' do |sp|
    sp.source_files = 'NovaMetrics/MLeaksFinder/Classes/**/*'
  end

  s.subspec 'VCProfiler' do |sp|
    sp.source_files = 'NovaMetrics/VCProfiler/Classes/**/*'
  end
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'NovaMetrics/Tests/**/*'
    test_spec.requires_app_host = true
  end  

end
