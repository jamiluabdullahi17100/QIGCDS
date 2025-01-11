;; Diplomatic Relations Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var civilization-counter uint u0)
(define-map civilizations uint {
    name: (string-ascii 50),
    description: (string-utf8 500),
    technology-level: uint,
    cultural-traits: (list 5 (string-ascii 20))
})

(define-map diplomatic-relations {civ1: uint, civ2: uint} {
    status: (string-ascii 20),
    trust-level: int,
    last-interaction: uint
})

;; Public Functions
(define-public (register-civilization (name (string-ascii 50)) (description (string-utf8 500)) (technology-level uint) (cultural-traits (list 5 (string-ascii 20))))
    (let ((civ-id (+ (var-get civilization-counter) u1)))
        (asserts! (and (>= technology-level u1) (<= technology-level u10)) err-invalid-parameters)
        (map-set civilizations civ-id {
            name: name,
            description: description,
            technology-level: technology-level,
            cultural-traits: cultural-traits
        })
        (var-set civilization-counter civ-id)
        (ok civ-id)
    )
)

(define-public (update-diplomatic-status (civ1 uint) (civ2 uint) (new-status (string-ascii 20)))
    (let ((current-relation (default-to {status: "neutral", trust-level: 0, last-interaction: u0}
                                        (map-get? diplomatic-relations {civ1: civ1, civ2: civ2}))))
        (asserts! (or (is-eq tx-sender contract-owner)
                      (is-some (map-get? civilizations civ1))
                      (is-some (map-get? civilizations civ2)))
                  err-unauthorized)
        (map-set diplomatic-relations {civ1: civ1, civ2: civ2}
                 (merge current-relation {
                     status: new-status,
                     last-interaction: block-height
                 }))
        (ok true)
    )
)

(define-public (update-trust-level (civ1 uint) (civ2 uint) (trust-change int))
    (let ((current-relation (default-to {status: "neutral", trust-level: 0, last-interaction: u0}
                                        (map-get? diplomatic-relations {civ1: civ1, civ2: civ2}))))
        (asserts! (or (is-eq tx-sender contract-owner)
                      (is-some (map-get? civilizations civ1))
                      (is-some (map-get? civilizations civ2)))
                  err-unauthorized)
        (map-set diplomatic-relations {civ1: civ1, civ2: civ2}
                 (merge current-relation {
                     trust-level: (+ (get trust-level current-relation) trust-change),
                     last-interaction: block-height
                 }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-civilization (civ-id uint))
    (map-get? civilizations civ-id)
)

(define-read-only (get-diplomatic-relation (civ1 uint) (civ2 uint))
    (map-get? diplomatic-relations {civ1: civ1, civ2: civ2})
)

(define-read-only (get-civilization-count)
    (var-get civilization-counter)
)

