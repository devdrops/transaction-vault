package logger

import (
	"os"
	"time"

	"github.com/devdrops/transaction-vault/infra/appinfo"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var logLevelSeverity = map[zapcore.Level]string{
	zapcore.DebugLevel:  "DEBUG",
	zapcore.InfoLevel:   "INFO",
	zapcore.WarnLevel:   "WARNING",
	zapcore.ErrorLevel:  "ERROR",
	zapcore.DPanicLevel: "CRITICAL",
	zapcore.PanicLevel:  "ALERT",
	zapcore.FatalLevel:  "EMERGENCY",
}

func syslogTimeEncoder(t time.Time, enc zapcore.PrimitiveArrayEncoder) {
	enc.AppendString(t.Format(time.RFC3339Nano))
}

func customEncodeLevel(level zapcore.Level, enc zapcore.PrimitiveArrayEncoder) {
	enc.AppendString(logLevelSeverity[level])
}

func InitGlobalLogger(env string) {
	highPriority := zap.LevelEnablerFunc(func(lvl zapcore.Level) bool {
		return lvl >= zapcore.ErrorLevel
	})
	lowPriority := zap.LevelEnablerFunc(func(lvl zapcore.Level) bool {
		return lvl < zapcore.ErrorLevel
	})

	stdout := zapcore.Lock(os.Stdout)
	stderr := zapcore.Lock(os.Stderr)

	encoderConfig := zapcore.EncoderConfig{
		MessageKey:    "msg",
		LevelKey:      "level",
		TimeKey:       "timestamp",
		CallerKey:     "file",
		StacktraceKey: "trace",
		EncodeLevel:   customEncodeLevel,
		EncodeTime:    syslogTimeEncoder,
		EncodeCaller:  zapcore.FullCallerEncoder,
	}

	var encoder zapcore.Encoder
	switch env {
	case "prd":
		encoder = zapcore.NewJSONEncoder(encoderConfig)
	default:
		encoder = zapcore.NewConsoleEncoder(encoderConfig)
	}

	core := zapcore.NewTee(
		zapcore.NewCore(encoder, stderr, highPriority),
		zapcore.NewCore(encoder, stdout, lowPriority),
	)

	logger := zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))
	defer logger.Sync()

	logger = logger.With(
		zap.String("app_name", appinfo.AppName),
		zap.String("app_version", appinfo.AppVersion),
		zap.String("app_build_at", appinfo.AppBuildAt),
	)

	zap.ReplaceGlobals(logger)
}
