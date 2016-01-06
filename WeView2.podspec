Pod::Spec.new do |s|
	s.name				= 'WeView2'
	s.version			= '1.0.0'
	s.summary			= 'WeView layout framework'
	s.homepage			= 'http://charlesmchen.github.io/WeView2/'
	s.license			= 'MIT'
	s.authors			= { 'Matthew Chen' => 'charlesmchen@gmail.com'}
	s.source			= { :git => 'https://github.com/sarsonj/WeView2.git' }
	s.ios.deployment_target = "6.0"
	s.tvos.deployment_target = "9.0"

	s.source_files		= 'WeView/**/*'
	s.frameworks		= 'CoreGraphics'
	s.requires_arc		= true
end
