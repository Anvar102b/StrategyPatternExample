import UIKit

protocol ValidateStrategy {
func validate(text: String) -> Result<Bool,NSError>
}


struct SnilsValidator: ValidateStrategy {
    func validate(text: String) -> Result<Bool, NSError> {
        if text.count == 0 {
            return .failure(NSError(domain: "snilsDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "СНИЛС пуст"]))
        } else if text.count != 11 {
            return .failure(NSError(domain: "snilsDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "Снилс должен содержать 11 цифр"]))
        } else {
            var sum: Int = 0
            for index in (0...9) {
                let array = Array(text)
                let letter = String(array[index])
                sum += ((Int(letter) ?? 0) * (9 - index))
            }
            var checkDigit = 0
            if sum < 100 {
                checkDigit = sum
            } else if sum > 101 {
                checkDigit = sum % 101
                if checkDigit == 100 {
                    checkDigit = 0
                }
            }
            if checkDigit != Int(text.suffix(2)) {
                return .failure(NSError(domain: "snilsDomain", code: 4, userInfo: [NSLocalizedDescriptionKey: "Снилс указан неверно"]))
            }
        }
        return .success(true)
    }

}

struct EmailValidatior: ValidateStrategy {
    
    func validate(text: String) -> Result<Bool, NSError> {
        func isValidEmail() -> Bool {
            let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
            let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
            return emailTest.evaluate(with: text)
        }
        
        if isValidEmail() {
            return .success(true)
        } else {
            return .failure(NSError(domain: "emailDomain", code: 4, userInfo: [NSLocalizedDescriptionKey: "email указан неверно"]))
        }
    }
}

class Context {
    var strategy: ValidateStrategy!
    func validate(text: String) -> String {
        let result = strategy.validate(text: text)
        switch result {
        case .success(_):
            return "✅"
        case .failure(let error):
         return (error.localizedDescription)
        }
    }
    
    func setStrategy(strategy: ValidateStrategy) {
        self.strategy = strategy
    }
}

let context = Context()
context.setStrategy(strategy: SnilsValidator())
print(context.validate(text: "11223344595"))


context.setStrategy(strategy: EmailValidatior())
print(context.validate(text: "mustFail"))
