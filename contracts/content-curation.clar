;; Content Curation Contract
;; Curates customer service content

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_NOT_FOUND (err u401))
(define-constant ERR_INVALID_STATUS (err u402))

;; Data maps
(define-map content-reviews uint {
    reviewer: principal,
    article-id: uint,
    status: (string-ascii 20),
    feedback: (string-ascii 200),
    reviewed-at: uint
})

(define-map curator-permissions principal bool)
(define-data-var next-review-id uint u1)

;; Grant curator permissions
(define-public (grant-curator-permission (curator principal))
    (begin
        (map-set curator-permissions curator true)
        (ok true)
    )
)

;; Submit content for review
(define-public (submit-review (article-id uint) (status (string-ascii 20)) (feedback (string-ascii 200)))
    (let ((review-id (var-get next-review-id)))
        (begin
            (asserts! (default-to false (map-get? curator-permissions tx-sender)) ERR_UNAUTHORIZED)
            (asserts! (or (is-eq status "approved") (is-eq status "rejected") (is-eq status "pending")) ERR_INVALID_STATUS)
            (map-set content-reviews review-id {
                reviewer: tx-sender,
                article-id: article-id,
                status: status,
                feedback: feedback,
                reviewed-at: block-height
            })
            (var-set next-review-id (+ review-id u1))
            (ok review-id)
        )
    )
)

;; Get review
(define-read-only (get-review (review-id uint))
    (map-get? content-reviews review-id)
)

;; Check if user is curator
(define-read-only (is-curator (user principal))
    (default-to false (map-get? curator-permissions user))
)

;; Revoke curator permissions
(define-public (revoke-curator-permission (curator principal))
    (begin
        (map-delete curator-permissions curator)
        (ok true)
    )
)
