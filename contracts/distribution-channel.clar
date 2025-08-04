;; Distribution Channel Verification Contract
;; Tracks the movement of drugs from manufacturers to distributors to pharmacies

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-SHIPMENT-EXISTS (err u301))
(define-constant ERR-SHIPMENT-NOT-FOUND (err u302))
(define-constant ERR-INVALID-INPUT (err u303))
(define-constant ERR-DISTRIBUTOR-NOT-FOUND (err u304))
(define-constant ERR-INVALID-STATUS (err u305))

;; Data Variables
(define-data-var next-shipment-id uint u1)
(define-data-var next-distributor-id uint u1)

;; Data Maps
(define-map distributors
  { distributor-id: uint }
  {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    address: (string-ascii 200),
    contact-info: (string-ascii 100),
    certification: (string-ascii 50),
    is-authorized: bool,
    registered-by: principal,
    registration-date: uint
  }
)

(define-map shipments
  { shipment-id: uint }
  {
    batch-id: uint,
    from-entity: (string-ascii 100),
    to-entity: (string-ascii 100),
    distributor-id: uint,
    quantity: uint,
    shipment-date: uint,
    expected-delivery: uint,
    actual-delivery: (optional uint),
    status: (string-ascii 20),
    tracking-number: (string-ascii 50),
    transport-conditions: (string-ascii 200),
    created-by: principal
  }
)

(define-map shipment-checkpoints
  { shipment-id: uint, checkpoint-sequence: uint }
  {
    location: (string-ascii 100),
    timestamp: uint,
    status: (string-ascii 20),
    temperature: (optional int),
    humidity: (optional uint),
    notes: (string-ascii 200),
    recorded-by: principal
  }
)

(define-map authorized-distributors principal bool)
(define-map authorized-logistics principal bool)

;; Authorization Functions
(define-private (is-distributor (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    (default-to false (map-get? authorized-distributors user))
  )
)

(define-private (is-logistics-authorized (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    (default-to false (map-get? authorized-logistics user))
  )
)

;; Public Functions

;; Add authorized distributor
(define-public (add-authorized-distributor (distributor principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-distributors distributor true))
  )
)

;; Add authorized logistics provider
(define-public (add-authorized-logistics (logistics principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-logistics logistics true))
  )
)

;; Register a new distributor
(define-public (register-distributor
  (name (string-ascii 100))
  (license-number (string-ascii 50))
  (address (string-ascii 200))
  (contact-info (string-ascii 100))
  (certification (string-ascii 50))
)
  (let
    (
      (distributor-id (var-get next-distributor-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len license-number) u0) ERR-INVALID-INPUT)

    (map-set distributors
      { distributor-id: distributor-id }
      {
        name: name,
        license-number: license-number,
        address: address,
        contact-info: contact-info,
        certification: certification,
        is-authorized: true,
        registered-by: tx-sender,
        registration-date: block-height
      }
    )

    (var-set next-distributor-id (+ distributor-id u1))
    (print { event: "distributor-registered", distributor-id: distributor-id, name: name })
    (ok distributor-id)
  )
)

;; Create a new shipment
(define-public (create-shipment
  (batch-id uint)
  (from-entity (string-ascii 100))
  (to-entity (string-ascii 100))
  (distributor-id uint)
  (quantity uint)
  (expected-delivery uint)
  (tracking-number (string-ascii 50))
  (transport-conditions (string-ascii 200))
)
  (let
    (
      (shipment-id (var-get next-shipment-id))
      (distributor (map-get? distributors { distributor-id: distributor-id }))
    )
    (asserts! (is-distributor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some distributor) ERR-DISTRIBUTOR-NOT-FOUND)
    (asserts! (> quantity u0) ERR-INVALID-INPUT)
    (asserts! (> expected-delivery block-height) ERR-INVALID-INPUT)

    (map-set shipments
      { shipment-id: shipment-id }
      {
        batch-id: batch-id,
        from-entity: from-entity,
        to-entity: to-entity,
        distributor-id: distributor-id,
        quantity: quantity,
        shipment-date: block-height,
        expected-delivery: expected-delivery,
        actual-delivery: none,
        status: "in-transit",
        tracking-number: tracking-number,
        transport-conditions: transport-conditions,
        created-by: tx-sender
      }
    )

    (var-set next-shipment-id (+ shipment-id u1))
    (print { event: "shipment-created", shipment-id: shipment-id, batch-id: batch-id, tracking-number: tracking-number })
    (ok shipment-id)
  )
)

;; Add checkpoint to shipment
(define-public (add-shipment-checkpoint
  (shipment-id uint)
  (checkpoint-sequence uint)
  (location (string-ascii 100))
  (status (string-ascii 20))
  (temperature (optional int))
  (humidity (optional uint))
  (notes (string-ascii 200))
)
  (let
    (
      (shipment (map-get? shipments { shipment-id: shipment-id }))
    )
    (asserts! (is-logistics-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some shipment) ERR-SHIPMENT-NOT-FOUND)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)

    (map-set shipment-checkpoints
      { shipment-id: shipment-id, checkpoint-sequence: checkpoint-sequence }
      {
        location: location,
        timestamp: block-height,
        status: status,
        temperature: temperature,
        humidity: humidity,
        notes: notes,
        recorded-by: tx-sender
      }
    )

    (print { event: "checkpoint-added", shipment-id: shipment-id, location: location, status: status })
    (ok true)
  )
)

;; Update shipment status
(define-public (update-shipment-status (shipment-id uint) (new-status (string-ascii 20)))
  (let
    (
      (shipment (map-get? shipments { shipment-id: shipment-id }))
    )
    (asserts! (is-logistics-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some shipment) ERR-SHIPMENT-NOT-FOUND)

    (map-set shipments
      { shipment-id: shipment-id }
      (merge (unwrap-panic shipment) { status: new-status })
    )

    (print { event: "shipment-status-updated", shipment-id: shipment-id, status: new-status })
    (ok true)
  )
)

;; Mark shipment as delivered
(define-public (mark-delivered (shipment-id uint))
  (let
    (
      (shipment (map-get? shipments { shipment-id: shipment-id }))
    )
    (asserts! (is-logistics-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some shipment) ERR-SHIPMENT-NOT-FOUND)

    (map-set shipments
      { shipment-id: shipment-id }
      (merge (unwrap-panic shipment) {
        status: "delivered",
        actual-delivery: (some block-height)
      })
    )

    (print { event: "shipment-delivered", shipment-id: shipment-id })
    (ok true)
  )
)

;; Read-only Functions

;; Get distributor information
(define-read-only (get-distributor (distributor-id uint))
  (map-get? distributors { distributor-id: distributor-id })
)

;; Get shipment information
(define-read-only (get-shipment (shipment-id uint))
  (map-get? shipments { shipment-id: shipment-id })
)

;; Get shipment checkpoint
(define-read-only (get-shipment-checkpoint (shipment-id uint) (checkpoint-sequence uint))
  (map-get? shipment-checkpoints { shipment-id: shipment-id, checkpoint-sequence: checkpoint-sequence })
)

;; Get next shipment ID
(define-read-only (get-next-shipment-id)
  (var-get next-shipment-id)
)

;; Get next distributor ID
(define-read-only (get-next-distributor-id)
  (var-get next-distributor-id)
)
