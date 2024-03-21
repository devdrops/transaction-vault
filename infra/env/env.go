package env

import "os"

const (
	localEnv      string = "local"
	productionEnv string = "prd"

	defaultEnvironment string = localEnv
)

func GetEnvironment() string {
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = defaultEnvironment
	}

	return env
}
