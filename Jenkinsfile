
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION       = 'ap-south-1'
        AWS_ACCOUNT_ID   = '351083991382'
        ECR_REPOSITORY   = 'devops-flask-api'
        IMAGE_NAME       = 'devops-flask-api'
        REGISTRY         = '351083991382.dkr.ecr.ap-south-1.amazonaws.com'

        REMOTE_HOST      = 'ec2-user@172.31.13.199'
        ANSIBLE_CONFIG   = 'ansible/ansible.cfg'

        EKS_CLUSTER_NAME = 'devops-capstone-eks'
        K8S_NAMESPACE    = 'devops-capstone'
        K8S_DEPLOYMENT   = 'devops-flask-api'
        K8S_CONTAINER    = 'flask-api'
    }

    stages {

        // ==========================================
        // STAGE 1: CHECKOUT
        // ==========================================

        stage('Checkout') {
            steps {
                echo 'Checking out application source from GitHub.'

                git branch: 'main',
                    url: 'https://github.com/Ayushgautam2007/Devops-Project.git'

                sh '''
                    set -eu

                    echo "========== SOURCE REVISION =========="
                    git log -1 --oneline

                    echo "========== WORKSPACE =========="
                    pwd
                '''
            }
        }

        // ==========================================
        // STAGE 2: AUTOMATED TESTING
        // ==========================================

        stage('Automated Tests') {
            steps {
                sh '''
                    set -eu

                    echo "========== PYTHON ENVIRONMENT =========="

                    python3 --version
                    python3 -m venv .venv

                    . .venv/bin/activate

                    python -m pip install --upgrade pip
                    python -m pip install -r app/requirements.txt
                    python -m pip install pytest

                    echo "========== RUN AUTOMATED TESTS =========="

                    python -m pytest -v tests/
                '''
            }
        }

        // ==========================================
        // STAGE 3: BUILD AND PUSH TO ECR
        // ==========================================

        stage('Build and Push to ECR') {
            steps {
                sh '''
                    set -eu

                    IMAGE="$REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"

                    echo "========== AWS IDENTITY =========="

                    aws sts get-caller-identity

                    echo "========== ECR LOGIN =========="

                    aws ecr get-login-password \
                        --region "$AWS_REGION" |
                    docker login \
                        --username AWS \
                        --password-stdin "$REGISTRY"

                    echo "========== BUILD IMAGE =========="

                    docker build -t "$IMAGE" .

                    echo "========== PUSH IMAGE =========="

                    docker push "$IMAGE"

                    echo "Published image: $IMAGE"
                '''
            }
        }

        // ==========================================
        // STAGE 4: DOCKER HOST DEPLOYMENT
        // EXISTING DEPLOYMENT AND ROLLBACK PRESERVED
        // ==========================================

        stage('Deploy to Docker Server') {
            steps {
                sshagent(credentials: ['docker-server-ssh']) {

                    sh '''
                        set -eu

                        IMAGE="$REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"

                        echo "========== DEPLOYMENT TARGET =========="

                        echo "$REMOTE_HOST"
                        echo "Image: $IMAGE"

                        ssh \
                            -o BatchMode=yes \
                            "$REMOTE_HOST" \
                            "bash -s -- '$IMAGE' '$BUILD_NUMBER' '$AWS_REGION' '$REGISTRY'" \
                            <<'REMOTE_SCRIPT'

set -eu

IMAGE="$1"
BUILD_NO="$2"
AWS_REGION="$3"
REGISTRY="$4"

CANDIDATE="flask-api-candidate-$BUILD_NO"
ROLLBACK="flask-api-rollback-$BUILD_NO"
FAILED="flask-api-failed-$BUILD_NO"

echo "========== CHECK RECOVERY CONTAINERS =========="

for name in "$ROLLBACK" "$FAILED"; do
    if docker inspect "$name" >/dev/null 2>&1; then
        echo "ERROR: Recovery container already exists: $name"
        exit 1
    fi
done

echo "========== ECR LOGIN ON APP SERVER =========="

aws ecr get-login-password \
    --region "$AWS_REGION" |
docker login \
    --username AWS \
    --password-stdin "$REGISTRY"

echo "========== PULL IMAGE =========="

docker pull "$IMAGE"

echo "========== START CANDIDATE =========="

docker rm -f "$CANDIDATE" 2>/dev/null || true

docker run -d \
    --name "$CANDIDATE" \
    --restart unless-stopped \
    -p 127.0.0.1:9091:8080 \
    "$IMAGE"

sleep 4

echo "========== CANDIDATE HEALTH CHECK =========="

if ! curl --fail --silent --show-error \
    --max-time 5 \
    http://127.0.0.1:9091/health; then

    echo "ERROR: Candidate health check failed."

    docker logs "$CANDIDATE" || true
    docker rm -f "$CANDIDATE" || true

    exit 1
fi

echo
echo "Candidate health check passed."

docker rm -f "$CANDIDATE"

echo "========== IDENTIFY PRODUCTION CONTAINER =========="

OLD="$(docker ps --filter publish=9090 --format '{{.Names}}' | head -n 1)"

if [ -z "$OLD" ]; then
    echo "ERROR: No running container owns port 9090."
    exit 1
fi

echo "Current production container: $OLD"

if [ "$OLD" != "flask-api" ] &&
   docker inspect flask-api >/dev/null 2>&1; then

    if docker inspect "$FAILED" >/dev/null 2>&1; then
        echo "ERROR: Cannot safely preserve existing flask-api container."
        exit 1
    fi

    docker rename flask-api "$FAILED"
fi

echo "========== PRESERVE CURRENT PRODUCTION =========="

docker stop "$OLD"
docker rename "$OLD" "$ROLLBACK"

echo "Previous production container preserved as: $ROLLBACK"

echo "========== START NEW PRODUCTION =========="

if ! docker run -d \
    --name flask-api \
    --restart unless-stopped \
    -p 127.0.0.1:9090:8080 \
    "$IMAGE"; then

    echo "ERROR: New production container failed to start."

    docker rm -f flask-api 2>/dev/null || true

    if ! docker start "$ROLLBACK"; then
        echo "CRITICAL: Automatic rollback failed."
        exit 1
    fi

    exit 1
fi

sleep 4

echo "========== PRODUCTION HEALTH CHECK =========="

if curl --fail --silent --show-error \
    --max-time 5 \
    http://127.0.0.1:9090/health; then

    echo
    echo "Production health check passed."
    echo "Deployed image: $IMAGE"
    echo "Previous container preserved as: $ROLLBACK"

else

    echo
    echo "ERROR: Production health check failed."

    docker logs flask-api || true
    docker rm -f flask-api || true

    if ! docker start "$ROLLBACK"; then
        echo "CRITICAL: Automatic rollback failed."
        exit 1
    fi

    echo "Previous production container restarted."

    exit 1
fi

echo "========== RUNNING CONTAINERS =========="

docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

REMOTE_SCRIPT
                    '''
                }
            }
        }

        // ==========================================
        // STAGE 5: ANSIBLE VALIDATION
        // ==========================================

        stage('Ansible Post-Deployment Validation') {
            steps {
                sh '''
                    set -eu

                    echo "========== ANSIBLE VERSION =========="

                    ansible --version

                    echo "========== INVENTORY VALIDATION =========="

                    ansible-inventory \
                        -i ansible/inventory/hosts.ini \
                        --list

                    echo "========== DOCKER HEALTH VALIDATION =========="

                    ansible-playbook \
                        -i ansible/inventory/hosts.ini \
                        ansible/playbooks/docker_health.yml

                    echo "========== DISK USAGE VALIDATION =========="

                    ansible-playbook \
                        -i ansible/inventory/hosts.ini \
                        ansible/playbooks/disk_check.yml

                    echo "ANSIBLE POST-DEPLOYMENT VALIDATION PASSED"
                '''
            }
        }

        // ==========================================
        // STAGE 6: EKS DEPLOYMENT
        // NEW CI/CD STAGE
        // ==========================================

        stage('Deploy to Amazon EKS') {
            steps {
                sh '''
                    set -eu

                    IMAGE="$REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"

                    echo "========== EKS DEPLOYMENT INFORMATION =========="

                    echo "Cluster: $EKS_CLUSTER_NAME"
                    echo "Namespace: $K8S_NAMESPACE"
                    echo "Deployment: $K8S_DEPLOYMENT"
                    echo "Image: $IMAGE"

                    echo "========== AWS IDENTITY =========="

                    aws sts get-caller-identity

                    echo "========== UPDATE KUBECONFIG =========="

                    aws eks update-kubeconfig \
                        --region "$AWS_REGION" \
                        --name "$EKS_CLUSTER_NAME"

                    echo "========== VERIFY EKS ACCESS =========="

                    kubectl get nodes

                    echo "========== VERIFY NAMESPACE =========="

                    kubectl get namespace "$K8S_NAMESPACE" \
                        --ignore-not-found

                    echo "========== CREATE DYNAMIC MANIFEST =========="

                    RENDERED_MANIFEST="$(mktemp)"
                    export RENDERED_MANIFEST

                    trap 'rm -f "$RENDERED_MANIFEST"' EXIT

                    sed -E \
                        "s|^([[:space:]]*image:).*|\\1 $IMAGE|" \
                        k8s/deployment.yaml \
                        > "$RENDERED_MANIFEST"

                    echo "Rendered deployment image: $IMAGE"

                    echo "========== APPLY DEPLOYMENT =========="

                    kubectl apply -f "$RENDERED_MANIFEST"

                    echo "========== APPLY SERVICE =========="

                    kubectl apply -f k8s/service.yaml

                    echo "========== APPLY INGRESS =========="

                    kubectl apply -f k8s/ingress.yaml

                    echo "========== WAIT FOR DEPLOYMENT ROLLOUT =========="

                    kubectl rollout status \
                        deployment/"$K8S_DEPLOYMENT" \
                        -n "$K8S_NAMESPACE" \
                        --timeout=300s

                    echo "========== VERIFY DEPLOYED IMAGE =========="

                    ACTUAL_IMAGE=$(kubectl get deployment "$K8S_DEPLOYMENT" \
                        -n "$K8S_NAMESPACE" \
                        -o jsonpath='{.spec.template.spec.containers[?(@.name=="flask-api")].image}')

                    echo "Expected image: $IMAGE"
                    echo "Actual image:   $ACTUAL_IMAGE"

                    if [ "$ACTUAL_IMAGE" != "$IMAGE" ]; then
                        echo "ERROR: Deployed image does not match build image."
                        exit 1
                    fi

                    echo "========== VERIFY PODS =========="

                    kubectl get pods \
                        -n "$K8S_NAMESPACE" \
                        -o wide

                    echo "========== VERIFY SERVICE =========="

                    kubectl get service \
                        -n "$K8S_NAMESPACE"

                    echo "========== VERIFY INGRESS =========="

                    kubectl get ingress \
                        -n "$K8S_NAMESPACE"

                    echo "========== WAIT FOR ALB HOSTNAME =========="

                    ALB_HOST=""

                    for attempt in $(seq 1 30); do

                        ALB_HOST=$(kubectl get ingress devops-flask-api \
                            -n "$K8S_NAMESPACE" \
                            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
                            2>/dev/null || true)

                        if [ -n "$ALB_HOST" ]; then
                            break
                        fi

                        echo "Waiting for ALB hostname: attempt $attempt/30"
                        sleep 10
                    done

                    if [ -z "$ALB_HOST" ]; then
                        echo "ERROR: ALB hostname was not assigned."
                        exit 1
                    fi

                    echo "ALB hostname: $ALB_HOST"

                    echo "========== TEST APPLICATION HEALTH =========="

                    curl \
                        --fail \
                        --silent \
                        --show-error \
                        --retry 12 \
                        --retry-delay 10 \
                        --retry-connrefused \
                        --max-time 15 \
                        "http://$ALB_HOST/health"

                    echo

                    echo "========== TEST USERS API =========="

                    curl \
                        --fail \
                        --silent \
                        --show-error \
                        --retry 12 \
                        --retry-delay 10 \
                        --retry-connrefused \
                        --max-time 15 \
                        "http://$ALB_HOST/api/users"

                    echo

                    echo "========== EKS DEPLOYMENT SUCCESS =========="

                    echo "Cluster: $EKS_CLUSTER_NAME"
                    echo "Namespace: $K8S_NAMESPACE"
                    echo "Image: $IMAGE"
                    echo "ALB: $ALB_HOST"

                    echo "EKS deployment and endpoint validation passed."
                '''
            }
        }
    }

    // ==========================================
    // POST BUILD ACTIONS
    // ==========================================

    post {

        success {
            echo '''
            PIPELINE SUCCESS:
            - Source checkout completed
            - Automated tests passed
            - Docker image pushed to ECR
            - Docker-host deployment completed
            - Ansible validation completed
            - EKS deployment completed
            - Kubernetes rollout verified
            - ALB application endpoints verified
            '''
        }

        failure {
            echo '''
            PIPELINE FAILED.

            Check the first failed stage and Jenkins console output.

            If Docker deployment succeeded but a later stage failed,
            verify Docker-host production health independently.

            If EKS deployment failed, inspect Kubernetes Deployment,
            Pods, Events, and image pull errors before retrying.
            '''
        }

        always {
            echo "Build number: ${BUILD_NUMBER}"
            echo "ECR image: ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
            echo "EKS cluster: ${EKS_CLUSTER_NAME}"
            echo "Kubernetes namespace: ${K8S_NAMESPACE}"
        }
    }
}
