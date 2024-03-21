package transaction

type Service interface {
	Create(trx Transaction) error
	Update(trx Transaction) error
}
