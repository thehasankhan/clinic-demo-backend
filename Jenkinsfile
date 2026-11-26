pipeline {
    agent { label 'docker-linux' }

    options {
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Build and test') {
            steps {
                sh './mvnw -B -ntp clean verify'
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/TEST-*.xml',
                        skipPublishingChecks: true
                }
            }
        }

        stage('Build image') {
            steps {
                sh 'docker build --platform linux/amd64 -t "petclinic-rest:ci-$BUILD_NUMBER" .'
            }
        }

        stage('Smoke test') {
            steps {
                sh '''
                    set -eu
                    container=$(docker run -d --platform linux/amd64 \\
                        -e SPRING_PROFILES_ACTIVE=h2,spring-data-jpa \\
                        -p 127.0.0.1::9966 "petclinic-rest:ci-$BUILD_NUMBER")
                    trap 'docker rm -f "$container" >/dev/null' EXIT
                    base="http://$(docker port "$container" 9966/tcp)/petclinic"

                    for attempt in $(seq 1 30); do
                        if health=$(curl -fsS --max-time 2 "$base/actuator/health" 2>/dev/null) &&
                            printf '%s\\n' "$health" | grep -Eq '"status"[[:space:]]*:[[:space:]]*"UP"'; then
                            owners=$(curl -fsS --max-time 5 "$base/api/owners")
                            printf '%s\\n' "$owners" | grep -Eq '"firstName"[[:space:]]*:[[:space:]]*"George"'
                            echo "Health and owners checks passed"
                            exit 0
                        fi
                        sleep 2
                    done

                    docker logs "$container"
                    exit 1
                '''
            }
        }
    }
}
