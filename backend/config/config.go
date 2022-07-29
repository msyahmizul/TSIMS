package config

import (
	"github.com/spf13/viper"
)

func InitConfig() error {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("/home/jiro/Documents/Dev/PSM2/backend")
	viper.AddConfigPath("./")
	err := viper.ReadInConfig()
	return err
}
