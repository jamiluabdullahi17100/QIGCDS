;; Diplomatic Achievement NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-parameters (err u102))

;; NFT Definition
(define-non-fungible-token diplomatic-achievement uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map token-metadata uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    achievement-type: (string-ascii 50),
    civilizations-involved: (list 5 uint),
    timestamp: uint,
    rarity: uint
})

;; Public Functions
(define-public (mint (name (string-ascii 100))
                     (description (string-utf8 1000))
                     (achievement-type (string-ascii 50))
                     (civilizations-involved (list 5 uint))
                     (rarity uint))
    (let ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and (>= rarity u1) (<= rarity u10)) err-invalid-parameters)
        (try! (nft-mint? diplomatic-achievement token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            achievement-type: achievement-type,
            civilizations-involved: civilizations-involved,
            timestamp: block-height,
            rarity: rarity
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? diplomatic-achievement token-id) err-not-token-owner)) err-not-token-owner)
        (try! (nft-transfer? diplomatic-achievement token-id tx-sender recipient))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)

