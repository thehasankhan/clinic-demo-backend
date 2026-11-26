@Library('delivery-platform-ci@v0.1.0') _

deliveryPipeline(
    buildCommand: './mvnw -B -ntp clean verify',
    testReports: 'target/surefire-reports/TEST-*.xml',
    imageRepository: 'petclinic-rest-library-trial',
    containerPort: 9966,
    smokeCommand: 'sh ci/smoke.sh'
)
