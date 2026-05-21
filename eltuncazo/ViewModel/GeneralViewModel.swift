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



class RegistroViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func registroRX(telefono: String, password: String) -> Observable<Result<JSON, Error>> {
        
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
        }
        
        isRequestInProgress = true
        
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiRegistro
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





class ListadoMenuPrincipalViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    @Published var error: Error?
    
    let disposeBag = DisposeBag()
    
    func listadoMenuPrincipalRX(id: String, completion: @escaping (Result<ModeloMenuPrincipal, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["id": id]
        
        Observable<ModeloMenuPrincipal>.create { observer in
            let request = AF.request(apiListadoMenuPrincipal,
                                     method: .post,
                                     parameters: parameters)
                .responseDecodable(of: ModeloMenuPrincipal.self) { response in
                    switch response.result {
                    case .success(let modelo):
                        observer.onNext(modelo)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                print("Error: \(error). Reintentando...")
                return Observable.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(modelo))
            },
            onError: { error in
                self.error = error
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}





