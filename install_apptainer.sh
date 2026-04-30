# Variables
export GOVERSION=1.26.2
export OS=linux
export ARCH=amd64

read -e -p "Please provide a directory to clone apptainer repo to: " APPTAINER_REPO_PREFIX

if [[ ! -d ${APPTAINER_REPO_PREFIX} || ! -w ${APPTAINER_REPO_PREFIX} ]]; then
  echo "${APPTAINER_REPO_PREFIX} does not exist, or requires sudo to write to. Please provide an existing writable directory"
  exit 1
fi

# update repositories
sudo apt-get update

# Install debian packages for dependencies
sudo apt-get install -y \
    build-essential \
    libseccomp-dev \
    libtalloc-dev \
    libattr1-dev \
    libprotobuf-c-dev \
    uidmap \
    fakeroot \
    cryptsetup \
    tzdata \
    dh-apparmor \
    curl wget git

sudo apt-get install -y libsubid-dev


# get latest GO version tarball
curl -o /tmp/go${GOVERSION}.${OS}-${ARCH}.tar.gz \
  https://dl.google.com/go/go${GOVERSION}.${OS}-${ARCH}.tar.gz

# Check if user already has a go version installed at this directory
if [ -d "/usr/local/go" ]; then
  echo "/usr/local/go already exists, user may have an existing go version installed"
  exit 1
fi

sudo tar -C /usr/local -xvf /tmp/go${GOVERSION}.${OS}-${ARCH}.tar.gz


echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

#Install apptainer
cd ${APPTAINER_REPO_PREFIX}

git clone https://github.com/apptainer/apptainer.git

cd apptainer && \
  ./mconfig && \
  cd builddir && \
  make && \
  sudo make install

apptainer --version

