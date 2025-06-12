;; Knowledge Manager Verification Contract
;; Validates and manages customer service knowledge managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Data maps
(define-map verified-managers principal bool)
(define-map manager-credentials principal {
    verification-date: uint,
    expertise-level: uint,
    specialization: (string-ascii 50)
})

;; Verify a knowledge manager
(define-public (verify-manager (manager principal) (expertise-level uint) (specialization (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-none (map-get? verified-managers manager)) ERR_ALREADY_VERIFIED)
        (map-set verified-managers manager true)
        (map-set manager-credentials manager {
            verification-date: block-height,
            expertise-level: expertise-level,
            specialization: specialization
        })
        (ok true)
    )
)

;; Check if manager is verified
(define-read-only (is-verified-manager (manager principal))
    (default-to false (map-get? verified-managers manager))
)

;; Get manager credentials
(define-read-only (get-manager-credentials (manager principal))
    (map-get? manager-credentials manager)
)

;; Revoke manager verification
(define-public (revoke-verification (manager principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-some (map-get? verified-managers manager)) ERR_NOT_FOUND)
        (map-delete verified-managers manager)
        (map-delete manager-credentials manager)
        (ok true)
    )
)
