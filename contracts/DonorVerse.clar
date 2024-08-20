
;; Define the contract
(define-data-var contract-owner principal tx-sender)

;; Define constants for errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))

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
  { id: uint }
  { donor: principal, beneficiary-id: uint, amount: uint, timestamp: uint })

(define-map utilization
  { id: uint }
  { beneficiary-id: uint, milestone: uint, description: (string-ascii 255), amount: uint, status: (string-ascii 20) })

;; Define data variables
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; Helper functions
(define-private (is-authorized (user principal) (required-role uint))
  (match (map-get? roles { user: user })
    role-data (>= (get role role-data) required-role)
    false))

(define-private (get-last-milestone (beneficiary-id uint))
  (fold + (map get-milestone (get-utilization beneficiary-id)) u0))

(define-private (get-milestone (util { id: uint }))
  (get milestone util))

;; Role management functions
(define-public (set-role (user principal) (new-role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err "Only the contract owner can set roles"))
    (ok (map-set roles { user: user } { role: new-role }))))

(define-public (remove-role (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err "Only the contract owner can remove roles"))
    (ok (map-delete roles { user: user }))))

;; Main functions
(define-public (register-beneficiary (name (string-ascii 50)) (description (string-ascii 255)) (target-amount uint))
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (asserts! (is-authorized tx-sender ROLE-MODERATOR) (err "Only moderators can register beneficiaries"))
    (map-insert beneficiaries
      { id: beneficiary-id }
      { name: name, description: description, target-amount: target-amount, received-amount: u0, status: "active" })
    (var-set beneficiary-count beneficiary-id)
    (ok beneficiary-id)))

(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    (err ERR-BENEFICIARY-NOT-FOUND)))

(define-public (donate (beneficiary-id uint) (amount uint))
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
        (new-received-amount (+ (get received-amount beneficiary) amount))
        (donation-id (+ (var-get donation-count) u1)))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set beneficiaries
      { id: beneficiary-id }
      (merge beneficiary { received-amount: new-received-amount }))
    (map-insert donations
      { id: donation-id }
      { donor: tx-sender, beneficiary-id: beneficiary-id, amount: amount, timestamp: block-height })
    (var-set donation-count donation-id)
    (ok true)))

(define-public (add-utilization (beneficiary-id uint) (description (string-ascii 255)) (amount uint))
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
        (milestone (+ (default-to u0 (get-last-milestone beneficiary-id)) u1))
        (utilization-id (+ (var-get utilization-count) u1)))
    (asserts! (is-authorized tx-sender ROLE_ADMIN) (err "Only admins can add utilization"))
    (map-insert utilization
      { id: utilization-id }
      { beneficiary-id: beneficiary-id, milestone: milestone, description: description, amount: amount, status: "pending" })
    (var-set utilization-count utilization-id)
    (ok milestone)))

(define-public (approve-utilization (beneficiary-id uint) (milestone uint))
  (let ((utilization-entry (unwrap! (map-get? utilization { id: milestone }) ERR-UTILIZATION-NOT-FOUND))
        (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (asserts! (is-authorized tx-sender ROLE_ADMIN) (err "Only admins can approve utilization"))
    (asserts! (<= (get amount utilization-entry) (get received-amount beneficiary)) (err "Insufficient funds to approve utilization"))
    (map-set utilization
      { id: milestone }
      (merge utilization-entry { status: "approved" }))
    (ok true)))

(define-read-only (get-donations (beneficiary-id uint))
  (map
    (lambda (donation)
      (get donation (unwrap! (map-get? donations { id: donation }) (err "Donation not found"))))
    (filter
      (lambda (donation)
        (is-eq (get beneficiary-id (unwrap! (map-get? donations { id: donation }) (err "Donation not found"))) beneficiary-id))
      (range u1 (var-get donation-count)))))

(define-read-only (get-utilization (beneficiary-id uint))
  (map
    (lambda (util)
      (get util (unwrap! (map-get? utilization { id: util }) (err "Utilization not found"))))
    (filter
      (lambda (util)
        (is-eq (get beneficiary-id (unwrap! (map-get? utilization { id: util }) (err "Utilization not found"))) beneficiary-id))
      (range u1 (var-get utilization-count)))))

;; Contract initialization
(define-private (initialize-contract)
  (begin
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })
    (var-set contract-owner tx-sender)))

(initialize-contract)
