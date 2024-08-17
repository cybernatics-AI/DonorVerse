;; Define the contract
(define-data-var contract-owner principal tx-sender)

;; Define constants for errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))

;; Define constants for roles
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; Define data maps
(define-map roles { user: principal } { role: uint })

(define-map beneficiaries 
  { id: uint } 
  { name: (string-ascii 50), description: (string-ascii 255), target-amount: uint, received-amount: uint, status: (string-ascii 20) })

(define-map donations
  { donor: principal, beneficiary-id: uint }
  { amount: uint, timestamp: uint })

(define-map utilization
  { beneficiary-id: uint, milestone: uint }
  { description: (string-ascii 255), amount: uint, status: (string-ascii 20) })

;; Define data variables
(define-data-var beneficiary-count uint u0)

;; Helper functions
(define-private (is-authorized (user principal) (required-role uint))
  (match (map-get? roles { user: user })
    role-data (>= (get role role-data) required-role)
    false))

(define-private (get-last-milestone (beneficiary-id uint))
  (fold + (map get-milestone (get-utilization beneficiary-id)) u0))

(define-private (get-milestone (util { beneficiary-id: uint, milestone: uint }))
  (get milestone util))

;; Role management functions
(define-public (set-role (user principal) (new-role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-set roles { user: user } { role: new-role }))))

(define-public (remove-role (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-delete roles { user: user }))))

;; Main functions
(define-public (register-beneficiary (name (string-ascii 50)) (description (string-ascii 255)) (target-amount uint))
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (asserts! (is-authorized tx-sender ROLE-MODERATOR) ERR-NOT-AUTHORIZED)
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
    (asserts! (is-authorized tx-sender ROLE_ADMIN) ERR-NOT-AUTHORIZED)
    (map-insert utilization
      { beneficiary-id: beneficiary-id, milestone: milestone }
      { description: description, amount: amount, status: "pending" })
    (ok milestone)))

(define-public (approve-utilization (beneficiary-id uint) (milestone uint))
  (let ((utilization-entry (unwrap! (map-get? utilization { beneficiary-id: beneficiary-id, milestone: milestone }) ERR-NOT-FOUND))
        (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-NOT-FOUND)))
    (asserts! (is-authorized tx-sender ROLE_ADMIN) ERR-NOT-AUTHORIZED)
    (asserts! (<= (get amount utilization-entry) (get received-amount beneficiary)) ERR-INSUFFICIENT-FUNDS)
    (map-set utilization
      { beneficiary-id: beneficiary-id, milestone: milestone }
      (merge utilization-entry { status: "approved" }))
    (ok true)))

(define-read-only (get-donations (beneficiary-id uint))
  (filter donations (lambda (donation) (is-eq (get beneficiary-id donation) beneficiary-id))))

(define-read-only (get-utilization (beneficiary-id uint))
  (filter utilization (lambda (util) (is-eq (get beneficiary-id util) beneficiary-id))))

;; Contract initialization
(define-private (initialize-contract)
  (begin
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })
    (var-set contract-owner tx-sender)))

(initialize-contract)
