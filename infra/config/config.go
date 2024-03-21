package config

import (
	"github.com/spf13/viper"
)

func New() (*viper.Viper, error) {
	cfg := viper.New()
	cfg.SetConfigName("config")
	cfg.AddConfigPath(".")
	if err := cfg.ReadInConfig(); err != nil {
		return nil, err
	}
	cfg.AutomaticEnv()

	return cfg, nil
}
