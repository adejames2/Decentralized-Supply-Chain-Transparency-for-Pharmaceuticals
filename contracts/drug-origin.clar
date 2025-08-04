;; Drug Origin Verification Contract
;; Records the source of active pharmaceutical ingredients (APIs) and excipients

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INGREDIENT-EXISTS (err u101))
(define-constant ERR-INGREDIENT-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))
(define-constant ERR-SUPPLIER-NOT-FOUND (err u104))

;; Data Variables
(define-data-var next-ingredient-id uint u1)
(define-data-var next-supplier-id uint u1)

;; Data Maps
(define-map suppliers
  { supplier-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    certification: (string-ascii 50),
    registration-date: uint,
    is-active: bool,
    registered-by: principal
  }
)

(define-map ingredients
  { ingredient-id: uint }
  {
    name: (string-ascii 100),
    type: (string-ascii 20),
    supplier-id: uint,
    batch-number: (string-ascii 50),
    manufacturing-date: uint,
    expiry-date: uint,
    quality-grade: (string-ascii 10),
    certification-hash: (string-ascii 64),
    registered-by: principal,
    registration-date: uint
  }
)

(define-map authorized-registrars principal bool)

;; Authorization Functions
(define-private (is-authorized (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    (default-to false (map-get? authorized-registrars user))
  )
)

;; Public Functions

;; Add authorized registrar
(define-public (add-authorized-registrar (registrar principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-registrars registrar true))
  )
)

;; Remove authorized registrar
(define-public (remove-authorized-registrar (registrar principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-delete authorized-registrars registrar))
  )
)

;; Register a new supplier
(define-public (register-supplier
  (name (string-ascii 100))
  (location (string-ascii 100))
  (certification (string-ascii 50))
)
  (let
    (
      (supplier-id (var-get next-supplier-id))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)

    (map-set suppliers
      { supplier-id: supplier-id }
      {
        name: name,
        location: location,
        certification: certification,
        registration-date: block-height,
        is-active: true,
        registered-by: tx-sender
      }
    )

    (var-set next-supplier-id (+ supplier-id u1))
    (print { event: "supplier-registered", supplier-id: supplier-id, name: name })
    (ok supplier-id)
  )
)

;; Register a new ingredient
(define-public (register-ingredient
  (name (string-ascii 100))
  (ingredient-type (string-ascii 20))
  (supplier-id uint)
  (batch-number (string-ascii 50))
  (manufacturing-date uint)
  (expiry-date uint)
  (quality-grade (string-ascii 10))
  (certification-hash (string-ascii 64))
)
  (let
    (
      (ingredient-id (var-get next-ingredient-id))
      (supplier (map-get? suppliers { supplier-id: supplier-id }))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some supplier) ERR-SUPPLIER-NOT-FOUND)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len batch-number) u0) ERR-INVALID-INPUT)
    (asserts! (> expiry-date manufacturing-date) ERR-INVALID-INPUT)

    (map-set ingredients
      { ingredient-id: ingredient-id }
      {
        name: name,
        type: ingredient-type,
        supplier-id: supplier-id,
        batch-number: batch-number,
        manufacturing-date: manufacturing-date,
        expiry-date: expiry-date,
        quality-grade: quality-grade,
        certification-hash: certification-hash,
        registered-by: tx-sender,
        registration-date: block-height
      }
    )

    (var-set next-ingredient-id (+ ingredient-id u1))
    (print { event: "ingredient-registered", ingredient-id: ingredient-id, name: name, supplier-id: supplier-id })
    (ok ingredient-id)
  )
)

;; Update supplier status
(define-public (update-supplier-status (supplier-id uint) (is-active bool))
  (let
    (
      (supplier (map-get? suppliers { supplier-id: supplier-id }))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some supplier) ERR-SUPPLIER-NOT-FOUND)

    (map-set suppliers
      { supplier-id: supplier-id }
      (merge (unwrap-panic supplier) { is-active: is-active })
    )

    (print { event: "supplier-status-updated", supplier-id: supplier-id, is-active: is-active })
    (ok true)
  )
)

;; Read-only Functions

;; Get supplier information
(define-read-only (get-supplier (supplier-id uint))
  (map-get? suppliers { supplier-id: supplier-id })
)

;; Get ingredient information
(define-read-only (get-ingredient (ingredient-id uint))
  (map-get? ingredients { ingredient-id: ingredient-id })
)

;; Get next ingredient ID
(define-read-only (get-next-ingredient-id)
  (var-get next-ingredient-id)
)

;; Get next supplier ID
(define-read-only (get-next-supplier-id)
  (var-get next-supplier-id)
)

;; Check if user is authorized
(define-read-only (is-user-authorized (user principal))
  (is-authorized user)
)
