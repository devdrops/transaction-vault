package env

import "testing"

func TestGetEnvironment(t *testing.T) {
	t.Run("Expected local behavior", func(t *testing.T) {
		t.Setenv("APP_ENV", localEnv)

		if env := GetEnvironment(); env != localEnv {
			t.Errorf("test failed, want %s got %s", localEnv, env)
		}
	})
	t.Run("Expected production behavior", func(t *testing.T) {
		t.Setenv("APP_ENV", productionEnv)

		if env := GetEnvironment(); env != productionEnv {
			t.Errorf("test failed, want %s got %s", productionEnv, env)
		}
	})
	t.Run("Expected default behavior", func(t *testing.T) {
		if env := GetEnvironment(); env != localEnv {
			t.Errorf("test failed, want %s got %s", localEnv, env)
		}
	})
	t.Run("Undesired behavior", func(t *testing.T) {
		t.Setenv("APP_ENV", "unknown")

		if env := GetEnvironment(); env != "unknown" {
			t.Errorf("test failed, want %s got %s", "unknown", env)
		}
	})
}
