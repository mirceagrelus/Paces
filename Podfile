platform :ios, '11.0'

use_frameworks!

def common_pods
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
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
end

target 'PacesKit' do
   common_pods
end

