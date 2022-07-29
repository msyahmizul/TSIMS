package ariesAgent

type agent struct {
	client *aries.Aries
}

func initClient() {
	framework, err := aries.New()
	if err != nil {
		println("Error creating framework:", err)
		//return err
	}
	ctx, err := framework.Context()
	if err != nil {
		println("Error creating framework:", err)
		//return err
	}
	//didexchangeClient, err := didexchange.New(ctx)
	if err != nil {
		println("Error creating framework:", err)
		//return err
	}

}
