package userModel

type User struct {
	DocumentID      string   `json:"$id,omitempty"`
	Username        string   `json:"username,omitempty"`
	Password        string   `json:"password,omitempty"`
	FileID          []string `json:"fileID"`
	UserType        string   `json:"userType,omitempty"`
	ApplicantStatus string   `json:"applicantStatus,omitempty"`
	Did             string   `json:"did,omitempty"`
	WalletID        string   `json:"walletID,omitempty"`
	RejectMessage   string   `json:"rejectMessage,omitempty"`
}
type UserData struct {
	UserID     string `json:"userID,omitempty"`
	IcCard     string `json:"icCard,omitempty"`
	FirstName  string `json:"firstName,omitempty"`
	LastName   string `json:"lastName,omitempty"`
	Gender     string `json:"gender,omitempty"`
	Dob        string `json:"dob,omitempty"`
	Address    string `json:"address,omitempty"`
	City       string `json:"city,omitempty"`
	State      string `json:"state,omitempty"`
	Postcode   string `json:"postcode"`
	ID         string `json:"$id,omitempty"`
	Collection string `json:"$collection,omitempty"`
}

func (u *User) CheckValidApplicantStatus(status string) bool {
	switch status {
	case ApplicantStatusPending:
		return true
	case ApplicantStatusApprove:
		return true
	case ApplicantStatusRejected:
		return true
	default:
		return false
	}
}

const (
	UserTypeAdmin   = "ADMIN"
	UserTypeRegular = "USER"

	ApplicantStatusPending  = "PENDING"
	ApplicantStatusApprove  = "APPROVE"
	ApplicantStatusRejected = "REJECTED"
)
