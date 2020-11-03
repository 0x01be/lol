FROM 0x01be/yosys as yosys
FROM 0x01be/prjtrellis as prjtrellis
FROM 0x01be/nextpnr:ecp5 as nextpnr
FROM 0x01be/verilator as verilator
FROM 0x01be/riscv-gnu-toolchain as riscv

FROM 0x01be/litex

COPY --from=yosys /opt/yosys/ /opt/yosys/
COPY --from=prjtrellis /opt/prjtrellis/ /opt/prjtrellis/
COPY --from=nextpnr /opt/nextpnr/ /opt/nextpnr/
COPY --from=riscv /opt/riscv/ /opt/riscv/
COPY --from=verilator /opt/verilator/ /opt/verilator/

ENV PATH ${PATH}:/opt/yosys/bin/:/opt/prjtrellis/bin/:/opt/nextpnr/bin/:/opt/verilator/bin/:/opt/riscv/bin/

ENV REVISION master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/enjoy-digital/linux-on-litex-vexriscv /linux-on-litex-vexriscv
RUN git clone --depth 1 --branch ${REVISION} https://github.com/litex-hub/linux-on-litex-vexriscv-prebuilt.git /linux-on-litex-vexriscv-prebuilt
RUN cp /linux-on-litex-vexriscv-prebuilt/buildroot/*  /linux-on-litex-vexriscv/buildroot/

WORKDIR /linux-on-litex-vexriscv

RUN /usr/bin/python3 ./make.py --board=versa_ecp5 --build

RUN apk --no-cache add --virtual sim-dependencies \
    libevent-dev \
    json-c-dev \
    perl \
    ccache

RUN sed -i.bak 's/^.*dump.main_time.*//g' /litex/litex/build/sim/core/veril.cpp

CMD ["/usr/bin/python3", "./sim.py"]

