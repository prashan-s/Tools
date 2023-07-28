//
//  LocalAuthenticationManager.swift
//  HostingApp
//
//  Created by Prashan Samarathunge on 2023-07-28.
//  Copyright © 2023 Bhasha. All rights reserved.
//

import Foundation
import LocalAuthentication

public typealias LAManager = LocalAuthenticationManager
public final class LocalAuthenticationManager{
    
    //MARK: TypeAlias
    
    public typealias LAMResultCompletion = (LAMResult) -> Void
    public typealias LAMResultSimplifiedCompletion = (LAMSimplifiedResult) -> Void
    
    //MARK: - Enum
    enum Mode{
        ///@description
        ///Fallbacks are also enabled
        case Default
        ///@description
        ///Only The Biometric options are used to authenticate
        case BioMetricsOnly
    }
    
    public enum LAMResult{
        case Success
        case Faliure(LAError.Code)
    }
    
    public enum LAMSimplifiedResult{
        case Success
        case CanRetryAgainWithAFaliure
        case BiometricLockout
        case BiometricNotAvailable
        case BiometicNotEnrolled
    }
    
    
    //MARK: - Classes
    
    
    
    //MARK: - Structs
    
    
    
    //MARK: - Constants
    
    
    
    //MARK: - Variables
    private static var NotSetError:Int = 9999
    private var currentContext:LAContext!
    private var error:NSError!
    
    //MARK: - IBOutlets
    
    
    
    //MARK: - Class Life Cycle
    init(mode:Mode = .Default) {
        let context = LAContext()
        switch mode{
        case .Default:
            break
        case .BioMetricsOnly:
            //Removes Fallback Titles
            context.localizedFallbackTitle = ""
        }
        self.currentContext = context
        self.error = createInitialError()
    }
    
    private func runOnMain(completion: @escaping () -> Void){
        DispatchQueue.main.async {
            completion()
        }
    }
    
   
   
    
}

//MARK: Helpers
extension LocalAuthenticationManager{
    
    private func createInitialError() -> NSError{
        let userInfo: [String : Any] = [
            NSLocalizedDescriptionKey :  NSLocalizedString("Not Used", value: "Empty Error", comment: ""),
            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Not Used", value: "Empty Error", comment: "")
        ]
        
        let error = NSError(domain: "com.helakuru.local.auth.error", code: Self.NotSetError, userInfo: userInfo)
        return error
    }
}

//MARK: Public Functions
extension LocalAuthenticationManager{
    
    public func evaluate(localizedReason: String = "Access requires authentication",
                         _ evaluation: @escaping LAManager.LAMResultCompletion ){
        
        let result = canEvaluatePolicy()
        if case LAMResult.Success = result{
            self.evaluvatePolicy(localizedReason: localizedReason) { evaluatedResult in
                
                evaluation(evaluatedResult)
                
            }
            
        } else {
            evaluation(result)
            
        }
    }
    
    public func evaluateWithSimplifiedResult(localizedReason: String = "Access requires authentication",
                                             _ evaluation: @escaping LAManager.LAMResultSimplifiedCompletion)  {
        
        self.evaluate(localizedReason: localizedReason) { lamResult in
            switch lamResult{
            case .Success:
                evaluation(.Success)
            case .Faliure(let error):
                switch error{
                case .authenticationFailed, .userFallback, .userCancel, .systemCancel:
                    evaluation(.CanRetryAgainWithAFaliure)
                case .biometryLockout:
                    evaluation(.BiometricLockout)
                case .biometryNotAvailable:
                    evaluation(.BiometricNotAvailable)
                case .biometryNotEnrolled:
                    evaluation(.BiometicNotEnrolled)
                default:
                    evaluation(.BiometricLockout)
                }
            }
        }
    }
    
    public func canEvaluatePolicy() -> LAMResult{
        if currentContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                            error: &error){
            
            return .Success
        }else{
            
            //Errors Occured
            if self.error.code == Self.NotSetError{
                
                return .Faliure(.invalidContext)
                
            }else{
                
                return asLAMResult(self.error)
                
            }
            
        }
    }
    
    public func evaluvatePolicy(localizedReason:String = "Access requires authentication",
                                completion: @escaping LAManager.LAMResultCompletion){
        
        self.currentContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                           localizedReason: localizedReason) {  [weak self] success, error in
            guard let `self` else {return}
            self.runOnMain {
                if success{
                    //Success Scenario
                    completion(.Success)
                }else{
                    
                    if let errorResult = error as? NSError{
                        return completion(self.asLAMResult(errorResult))
                    }else{
                        return completion(.Faliure(.invalidContext))
                    }
                    
                }
            }
        }
    }
    
    private func asLAMResult(_ error:NSError?) -> LAMResult{
        guard let error else {
            return .Faliure(.invalidContext)
        }
        if let errorResult = LAError.Code(rawValue: error.code){
            //Parsed Error
            return .Faliure(errorResult)
        }else{
            //Unknown Faliure
            return .Faliure(.invalidContext)
        }
    }
    
}