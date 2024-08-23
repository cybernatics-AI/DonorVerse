;; Enable Clarity 3.0 features
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

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
  { 
    name: (string-utf8 50), 
    description: (string-utf8 255), 
    target-amount: uint, 
    received-amount: uint, 
    status: (string-ascii 20)
  })

(define-map donations
  { id: uint }
  { donor: principal, beneficiary-id: uint, amount: uint, timestamp: uint })

(define-map utilization
  { id: uint }
  { 
    beneficiary-id: uint, 
    milestone: uint, 
    description: (string-utf8 255), 
    amount: uint, 
    status: (string-ascii 20)
  })

;; Define data variables
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; Helper functions
(define-private (is-authorized (user principal) (required-role uint))
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)))

(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count))

;; Role management functions
(define-public (set-role (user principal) (new-role uint))
  (begin
    (assert (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-set roles { user: user } { role: new-role }))))

(define-public (remove-role (user principal))
  (begin
    (assert (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (map-delete roles { user: user }))))

;; Main functions
(define-public (register-beneficiary (name (string-utf8 50)) (description (string-utf8 255)) (target-amount uint))
  (let 
    ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (begin
      (assert (is-authorized tx-sender ROLE-MODERATOR) ERR-NOT-AUTHORIZED)
      (map-set beneficiaries
        { id: beneficiary-id }
        { 
          name: name, 
          description: description, 
          target-amount: target-amount, 
          received-amount: u0, 
          status: "active" 
        })
      (var-set beneficiary-count beneficiary-id)
      (ok beneficiary-id))))

(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    ERR-BENEFICIARY-NOT-FOUND))

(define-public (donate (beneficiary-id uint) (amount uint))
  (let 
    ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
     (new-received-amount (+ (get received-amount beneficiary) amount))
     (donation-id (+ (var-get donation-count) u1)))
    (begin
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set beneficiaries
        { id: beneficiary-id }
        (merge beneficiary { received-amount: new-received-amount }))
      (map-set donations
        { id: donation-id }
        { donor: tx-sender, beneficiary-id: beneficiary-id, amount: amount, timestamp: block-height })
      (var-set donation-count donation-id)
      (ok true))))

(define-public (add-utilization (beneficiary-id uint) (description (string-utf8 255)) (amount uint))
  (let 
    ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
     (milestone (+ (get-last-milestone beneficiary-id) u1))
     (utilization-id (+ (var-get utilization-count) u1)))
    (begin
      (assert (is-authorized tx-sender ROLE-ADMIN) ERR-NOT-AUTHORIZED)
      (map-set utilization
        { id: utilization-id }
        { 
          beneficiary-id: beneficiary-id, 
          milestone: milestone, 
          description: description, 
          amount: amount, 
          status: "pending" 
        })
      (var-set utilization-count utilization-id)
      (ok milestone))))

(define-public (approve-utilization (beneficiary-id uint) (milestone uint))
  (let 
    ((utilization-entry (unwrap! (map-get? utilization { id: milestone }) ERR-UTILIZATION-NOT-FOUND))
     (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (begin
      (assert (is-authorized tx-sender ROLE-ADMIN) ERR-NOT-AUTHORIZED)
      (assert (<= (get amount utilization-entry) (get received-amount beneficiary)) ERR-INSUFFICIENT-FUNDS)
      (map-set utilization
        { id: milestone }
        (merge utilization-entry { status: "approved" }))
      (ok true))))

;; Helper function to check if a donation belongs to a beneficiary
(define-private (donation-belongs-to-beneficiary? (donation { donor: principal, beneficiary-id: uint, amount: uint, timestamp: uint }) (target-beneficiary-id uint))
  (is-eq (get beneficiary-id donation) target-beneficiary-id))

;; Get donations for a specific beneficiary
(define-read-only (get-donations (beneficiary-id uint))
  (let ((all-donations (map get-donation (sequence u1 (var-get donation-count)))))
    (filter donation-belongs-to-beneficiary? all-donations beneficiary-id)))

;; Helper function to get a donation by ID
(define-private (get-donation (id uint))
  (default-to 
    { donor: tx-sender, beneficiary-id: u0, amount: u0, timestamp: u0 }
    (map-get? donations { id: id })))

;; Helper function to check if a utilization entry belongs to a beneficiary
(define-private (utilization-belongs-to-beneficiary? (util { beneficiary-id: uint, milestone: uint, description: (string-utf8 255), amount: uint, status: (string-ascii 20) }) (target-beneficiary-id uint))
  (is-eq (get beneficiary-id util) target-beneficiary-id))

;; Get utilization entries for a specific beneficiary
(define-read-only (get-utilization (beneficiary-id uint))
  (let ((all-utilizations (map get-utilization-entry (sequence u1 (var-get utilization-count)))))
    (filter utilization-belongs-to-beneficiary? all-utilizations beneficiary-id)))

;; Helper function to get a utilization entry by ID
(define-private (get-utilization-entry (id uint))
  (default-to 
    { beneficiary-id: u0, milestone: u0, description: "", amount: u0, status: "" }
    (map-get? utilization { id: id })))

;; Contract initialization
(define-private (initialize-contract)
  (begin
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })
    (var-set contract-owner tx-sender)))

(initialize-contract)
