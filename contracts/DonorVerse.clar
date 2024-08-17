;; Define the contract
(define-data-var admin principal tx-sender)

;; Define constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))

;; Define data maps
(define-map beneficiaries 
  { id: uint } 
  { name: (string-ascii 50), description: (string-ascii 255), target-amount: uint, received-amount: uint, status: (string-ascii 20) })

(define-map donations
  { donor: principal, beneficiary-id: uint }
  { amount: uint, timestamp: uint })

(define-map utilization
  { beneficiary-id: uint, milestone: uint }
  { description: (string-ascii 255), amount: uint, status: (string-ascii 20) })

;; Define functions
(define-public (register-beneficiary (name (string-ascii 50)) (description (string-ascii 255)) (target-amount uint))
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (map-insert beneficiaries 
      { id: beneficiary-id }
      { name: name, description: description, target-amount: target-amount, received-amount: u0, status: "active" })
    (var-set beneficiary-count beneficiary-id)
    (ok beneficiary-id)))

(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    (err ERR-NOT-FOUND)))

(define-public (donate (beneficiary-id uint) (amount uint))
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-NOT-FOUND))
        (new-received-amount (+ (get received-amount beneficiary) amount)))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set beneficiaries 
      { id: beneficiary-id }
      (merge beneficiary { received-amount: new-received-amount }))
    (map-insert donations
      { donor: tx-sender, beneficiary-id: beneficiary-id }
      { amount: amount, timestamp: block-height })
    (ok true)))

(define-public (add-utilization (beneficiary-id uint) (description (string-ascii 255)) (amount uint))
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-NOT-FOUND))
        (milestone (+ (default-to u0 (get-last-milestone beneficiary-id)) u1)))
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (map-insert utilization
      { beneficiary-id: beneficiary-id, milestone: milestone }
      { description: description, amount: amount, status: "pending" })
    (ok milestone)))

(define-public (approve-utilization (beneficiary-id uint) (milestone uint))
  (let ((utilization-entry (unwrap! (map-get? utilization { beneficiary-id: beneficiary-id, milestone: milestone }) ERR-NOT-FOUND))
        (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (asserts! (<= (get amount utilization-entry) (get received-amount beneficiary)) ERR-INSUFFICIENT-FUNDS)
    (map-set utilization
      { beneficiary-id: beneficiary-id, milestone: milestone }
      (merge utilization-entry { status: "approved" }))
    (ok true)))

(define-read-only (get-donations (beneficiary-id uint))
  (filter donations (lambda (donation) (is-eq (get beneficiary-id donation) beneficiary-id))))

(define-read-only (get-utilization (beneficiary-id uint))
  (filter utilization (lambda (util) (is-eq (get beneficiary-id util) beneficiary-id))))

;; Helper functions
(define-data-var beneficiary-count uint u0)

(define-private (get-last-milestone (beneficiary-id uint))
  (fold + (map get-milestone (get-utilization beneficiary-id)) u0))

(define-private (get-milestone (util { beneficiary-id: uint, milestone: uint }))
  (get milestone util))
