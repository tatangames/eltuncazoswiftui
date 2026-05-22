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


class ActualizarPasswordViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    
    let disposeBag = DisposeBag()
    
    func actualizarPasswordRX(id: String, password: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "id": id,
            "password": password
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(apiActualizarPassword,
                                     method: .post,
                                     parameters: parameters)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        observer.onNext(json)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { (_, error) -> Observable<Int> in
                print("Error: \(error). Reintentando...")
                return Observable.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { json in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(json))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}


class ListadoDireccionesViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    
    let disposeBag = DisposeBag()
    
    func listadoDireccionesRX(id: String, completion: @escaping (Result<ModeloListadoDirecciones, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["id": id]
        
        Observable<ModeloListadoDirecciones>.create { observer in
            let request = AF.request(apiListadoDirecciones, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloListadoDirecciones.self) { response in
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
            errors.enumerated().flatMap { (_, error) -> Observable<Int> in
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
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
    
    func seleccionarDireccionRX(id: String, dirid: Int, completion: @escaping (Result<JSON, Error>) -> Void) {
        
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "id": id,
            "dirid": dirid
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(apiSeleccionarDireccion, method: .post, parameters: parameters)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(JSON(data))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { json in
                self.loadingSpinner = false
                completion(.success(json))
            },
            onError: { error in
                self.loadingSpinner = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
    
    func eliminarDireccionRX(id: String, dirid: Int, completion: @escaping (Result<JSON, Error>) -> Void) {
        
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "id": id,
            "dirid": dirid
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(apiEliminarDireccion, method: .post, parameters: parameters)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(JSON(data))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { json in
                self.loadingSpinner = false
                completion(.success(json))
            },
            onError: { error in
                self.loadingSpinner = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}


class RegistroNuevaDireccionViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    
    let disposeBag = DisposeBag()
    
    func registrarDireccionRX(
        id: String,
        nombre: String,
        telefono: String,
        direccion: String,
        puntoReferencia: String,
        completion: @escaping (Result<JSON, Error>) -> Void
    ) {
        guard !isRequestInProgress else { return }
        
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "id": id,
            "nombre": nombre,
            "telefono": telefono,
            "direccion": direccion,
            "punto_referencia": puntoReferencia
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(apiRegistrarDireccion,
                                     method: .post,
                                     parameters: parameters)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        observer.onNext(json)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { (_, error) -> Observable<Int> in
                print("Error: \(error). Reintentando...")
                return Observable.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { json in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(json))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}


class ListadoProductosViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    
    let disposeBag = DisposeBag()
    
    func listadoProductosRX(idCategoria: Int, completion: @escaping (Result<ModeloListadoProductos, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["categoria": idCategoria]
        
        Observable<ModeloListadoProductos>.create { observer in
            let request = AF.request(apiListadoProductos,
                                     method: .post,
                                     parameters: parameters)
                .responseDecodable(of: ModeloListadoProductos.self) { response in
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
            errors.enumerated().flatMap { (_, error) -> Observable<Int> in
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
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}


class InformacionProductoViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func informacionProductoRX(idProducto: Int, completion: @escaping (Result<ModeloInformacionProducto, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["productoid": idProducto]
        
        Observable<ModeloInformacionProducto>.create { observer in
            let request = AF.request(apiInformacionProducto,
                                     method: .post,
                                     parameters: parameters)
                .responseDecodable(of: ModeloInformacionProducto.self) { response in
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
            errors.enumerated().flatMap { (_, _) -> Observable<Int> in
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
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}

class EnviarProductoCarritoViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func enviarProductoRX(clienteid: String, productoid: Int, cantidad: Int, nota: String, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "clienteid": clienteid,
            "productoid": productoid,
            "cantidad": cantidad,
            "notaproducto": nota
        ]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiAgregarProductoCarrito,
                                     method: .post,
                                     parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
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
        .subscribe(
            onNext: { modelo in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(modelo))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}




class ListadoCarritoViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func listadoCarritoRX(clienteid: String, completion: @escaping (Result<ModeloCarrito, Error>) -> Void) {
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["clienteid": clienteid]
        
        Observable<ModeloCarrito>.create { observer in
            let request = AF.request(apiVerCarrito, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloCarrito.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { _ in
                Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class BorrarCarritoViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func borrarCarritoRX(clienteid: String, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        loadingSpinner = true
        let parameters: [String: Any] = ["clienteid": clienteid]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiBorrarCarrito, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class BorrarProductoCarritoViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func borrarProductoRX(clienteid: String, carritoid: Int, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        loadingSpinner = true
        let parameters: [String: Any] = ["clienteid": clienteid, "carritoid": carritoid]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiEliminarProductoCarrito, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}


class InformacionProductoEditarViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func informacionProductoEditarRX(clienteid: String, carritoid: Int, completion: @escaping (Result<ModeloInformacionProductoEditar, Error>) -> Void) {
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "clienteid": clienteid,
            "carritoid": carritoid
        ]
        
        Observable<ModeloInformacionProductoEditar>.create { observer in
            let request = AF.request(apiVerProductoEditar, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloInformacionProductoEditar.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { _ in
                Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(modelo))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}

class ActualizarProductoEditadoViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func actualizarProductoRX(clienteid: String, cantidad: Int, carritoid: Int, nota: String, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "clienteid": clienteid,
            "cantidad": cantidad,
            "carritoid": carritoid,
            "nota": nota
        ]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiActualizarProductoEditado, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(modelo))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}


class InformacionOrdenParaEnviarViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func informacionOrdenRX(clienteid: String, completion: @escaping (Result<ModeloInformacionOrdenParaEnviar, Error>) -> Void) {
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["clienteid": clienteid]
        
        Observable<ModeloInformacionOrdenParaEnviar>.create { observer in
            let request = AF.request(apiVerOrdenParaEnviar, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloInformacionOrdenParaEnviar.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { _ in
                Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class EnviarOrdenFinalViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func enviarOrdenRX(clienteid: String, nota: String, version: String, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        guard !isRequestInProgress else { return }
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = [
            "clienteid": clienteid,
            "nota": nota,
            "version": version
        ]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiEnviarOrdenFinal, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class ListadoOrdenesViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func listadoOrdenesRX(clienteid: String, completion: @escaping (Result<ModeloListadoOrdenes, Error>) -> Void) {
        isRequestInProgress = true
        loadingSpinner = true
        
        let parameters: [String: Any] = ["clienteid": clienteid]
        
        Observable<ModeloListadoOrdenes>.create { observer in
            let request = AF.request(apiListadoOrdenes, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloListadoOrdenes.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { _ in
                Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.success(modelo))
            },
            onError: { error in
                self.loadingSpinner = false
                self.isRequestInProgress = false
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}





class InformacionOrdenViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func informacionOrdenRX(ordenid: Int, completion: @escaping (Result<ModeloOrdenesIndividual, Error>) -> Void) {
        isRequestInProgress = true
        loadingSpinner = true
        let parameters: [String: Any] = ["ordenid": ordenid]
        
        Observable<ModeloOrdenesIndividual>.create { observer in
            let request = AF.request(apiEstadoOrden, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloOrdenesIndividual.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { _ in
                Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; self.isRequestInProgress = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class ListadoProductosOrdenViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func listadoProductosRX(ordenid: Int, completion: @escaping (Result<ModeloProductosDeOrden, Error>) -> Void) {
        loadingSpinner = true
        let parameters: [String: Any] = ["ordenid": ordenid]
        
        Observable<ModeloProductosDeOrden>.create { observer in
            let request = AF.request(apiListadoProductosOrden, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloProductosDeOrden.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}

class CancelarOrdenViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func cancelarOrdenRX(ordenid: Int, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        loadingSpinner = true
        let parameters: [String: Any] = ["ordenid": ordenid]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiCancelarOrden, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}


class CompletarOrdenViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func completarOrdenRX(ordenid: Int, completion: @escaping (Result<ModeloDatosBasicos, Error>) -> Void) {
        loadingSpinner = true
        let parameters: [String: Any] = ["ordenid": ordenid]
        
        Observable<ModeloDatosBasicos>.create { observer in
            let request = AF.request(apiCompletarOrden, method: .post, parameters: parameters)
                .responseDecodable(of: ModeloDatosBasicos.self) { response in
                    switch response.result {
                    case .success(let modelo): observer.onNext(modelo); observer.onCompleted()
                    case .failure(let error): observer.onError(error)
                    }
                }
            return Disposables.create { request.cancel() }
        }
        .subscribe(
            onNext: { modelo in self.loadingSpinner = false; completion(.success(modelo)) },
            onError: { error in self.loadingSpinner = false; completion(.failure(error)) }
        )
        .disposed(by: disposeBag)
    }
}
