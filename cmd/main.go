package main

import (
	"github.com/devdrops/transaction-vault/infra/config"
	"github.com/devdrops/transaction-vault/infra/env"
	"github.com/devdrops/transaction-vault/infra/logger"

	"go.uber.org/zap"
)

func main() {
	// Logging
	logger.InitGlobalLogger(env.GetEnvironment())

	// Configuration
	_, err := config.New()
	if err != nil {
		zap.L().Fatal("failed to read config file",
			zap.Error(err),
		)
	}

	// Endpoints/Services

	zap.L().Info("application up and running")
}
