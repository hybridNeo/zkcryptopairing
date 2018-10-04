FROM quay.io/pypa/manylinux1_x86_64 as wheel_builder

ENV PYTHONUNBUFFERED=1
ENV PYBIN=/opt/python/cp37-cp37m/bin
ENV PYTHON_SYS_EXECUTABLE="$PYBIN/python"

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
ENV PATH /root/.cargo/bin:$PATH

RUN "${PYBIN}/pip" install -U pip setuptools wheel setuptools-rust

RUN mkdir -p /usr/src/pairing
WORKDIR /usr/src/pairing

COPY . /usr/src/pairing

RUN "${PYBIN}/python" setup.py bdist_wheel
RUN auditwheel repair dist/pypairing-0.1.0-cp37-cp37m-linux_x86_64.whl 


FROM python:alpine3.8
COPY --from=wheel_builder /usr/src/pairing/wheelhouse/ /usr/src/wheelhouse
COPY --from=wheel_builder /usr/src/pairing/dist/ /usr/src/dist

ENV PYTHONUNBUFFERED=1
RUN pip install --upgrade pip ipython
RUN apk --update add libgcc libc6-compat

WORKDIR /usr/src/app
COPY _manylinux.py /usr/local/bin/
RUN pip install /usr/src/wheelhouse/*.whl
