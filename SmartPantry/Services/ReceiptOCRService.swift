import Foundation
import UIKit
import Vision

public class ReceiptOCRService {
    public static let shared = ReceiptOCRService()
    
    public init() {}
    
    /// Executes Apple Vision text recognition asynchronously on a UIImage
    public func recognizeText(in image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "ReceiptOCRService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid image format"])))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success([]))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            completion(.success(recognizedStrings))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Generates realistic sample receipt raw lines for instant demo testing
    public func getSampleReceiptLines(for store: String) -> [String] {
        switch store.lowercased() {
        case let s where s.contains("trader"):
            return [
                "TRADER JOE'S #502",
                "721 S ARROYO PKWY, PASADENA CA",
                "09/14/2026 10:42 AM",
                "----------------------------------",
                "ORG BNLS CHKN BRST           $6.99",
                "WHL MLK 1GAL                 $4.29",
                "AVO 4PK                      $3.99",
                "PAS EGGS 12CT                $4.99",
                "STRW FRESH 1LB               $3.49",
                "ORG SPN 16OZ                 $2.99",
                "GND BEEF 80/20 1LB           $5.49",
                "SUBTOTAL                     $32.23",
                "TAX                          $2.58",
                "TOTAL                        $34.81",
                "VISA ****8821"
            ]
        case let s where s.contains("whole"):
            return [
                "WHOLE FOODS MARKET",
                "1050 S GRAND AVE, LOS ANGELES CA",
                "09/12/2026 03:15 PM",
                "----------------------------------",
                "OG BANANAS 2.5LB @ 0.69/LB   $1.73",
                "ORGANIC SALMON FILLET        $12.99",
                "OG BLUEBERRIES 18OZ          $5.99",
                "ARTISAN SOURDOUGH BREAD      $4.49",
                "GRK YOGURT PLAIN 32OZ        $5.29",
                "SUBTOTAL                     $30.49",
                "TAX                          $2.13",
                "TOTAL                        $32.62",
                "APPLE PAY ****1042"
            ]
        default:
            return [
                "KROGER SUPERMARKET #108",
                "123 MAIN STREET, DALLAS TX",
                "09/10/2026 11:20 AM",
                "----------------------------------",
                "CHKN THIGH 2.1LB @ 2.99/LB   $6.28",
                "CUCUMBER FRESH 3CT           $1.99",
                "CHED CHZ SHRED 8OZ           $2.79",
                "WHL WHT BREAD                $2.49",
                "SUBTOTAL                     $13.55",
                "TAX                          $1.08",
                "TOTAL                        $14.63",
                "MASTERCARD ****9901"
            ]
        }
    }
}
