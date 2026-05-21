//
//  LoginViewModel.swift
//  eltuncazo
//
//  Created by Jonathan on 20/5/26.
//


import Foundation
import RxSwift
import Alamofire
import SwiftyJSON
internal import Combine

class LoginViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func loginRX(telefono: String, password: String) -> Observable<Result<JSON, Error>> {
        
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
        }
        
        isRequestInProgress = true
        
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiLogin
            let parameters: [String: Any] = [
                "usuario": telefono,
                "password": password,        
            ]
            
            let request = AF.request(encodeURL, method: .post, parameters: parameters)
                .responseData { response in
                    self.loadingSpinner = false
                    self.isRequestInProgress = false
                    
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        observer.onNext(.success(json))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onNext(.failure(error))
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
