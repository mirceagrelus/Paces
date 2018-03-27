platform :ios, '11.0'

use_frameworks!

def common_pods
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'Action'
end

target 'Paces' do
    common_pods

    target 'PacesTests' do
        inherit! :search_paths
        pod 'RxBlocking', '~> 4.0'
        pod 'RxTest', '~> 4.0'
    end

    target 'PacesKitTests' do
        inherit! :search_paths
        pod 'RxBlocking', '~> 4.0'
        pod 'RxTest', '~> 4.0'
    end

    target 'PacesUITests' do
        inherit! :search_paths
    end
end

target 'PacesKit' do
   common_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
