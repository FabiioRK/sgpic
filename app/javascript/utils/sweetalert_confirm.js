import Swal from "sweetalert2";
window.Swal = Swal;

function confirmAction(message, onConfirm) {
    Swal.fire({
        title: "Confirmação necessária",
        text: message,
        icon: "warning",
        iconColor: "#ffcc00",
        showCancelButton: true,
        confirmButtonText: "Confirmar",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            popup: "custom-swal-popup",
            confirmButton: "custom-confirm-btn",
            cancelButton: "custom-cancel-btn",
        },
        buttonsStyling: false,
    }).then((result) => {
        if (result.isConfirmed) {
            onConfirm();
        }
    });
}

function alertConfirm() {
    document.querySelectorAll("[data-sweet-confirm]").forEach((element) => {
        element.addEventListener("click", (event) => {
            const form = event.target;

            if (form && form.classList.contains("confirm-post")) {
                const message = element.dataset.sweetConfirm;
                const url = element.href;
                const method = element.dataset.method || "patch";

                event.preventDefault();
                event.stopPropagation();

                confirmAction(message, () => {
                    fetch(url, {
                        method: method.toUpperCase(),
                        headers: {
                            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                        },
                    })
                        .then((response) => response.json())
                        .then((data) => {
                            if (data.success) {
                                Swal.fire({
                                    title: "Sucesso!",
                                    text: data.message,
                                    icon: "success",
                                    customClass: {
                                        confirmButton: "custom-ok-btn",
                                        popup: "custom-swal-popup",
                                    },
                                    buttonsStyling: false,
                                }).then(() => {
                                    Turbo.visit(window.location.href);
                                });
                            } else {
                                Swal.fire({
                                    title: "Erro!",
                                    text: data.message,
                                    icon: "error",
                                    customClass: {
                                        confirmButton: "custom-ok-btn",
                                        popup: "custom-swal-popup",
                                    },
                                    buttonsStyling: false,
                                }).then(() => {
                                    Turbo.visit(window.location.href);
                                });
                            }
                        })
                        .catch(() => {
                            Swal.fire({
                                title: "Erro!",
                                text: "Algo deu errado ao processar sua solicitação.",
                                icon: "error",
                                customClass: {
                                    confirmButton: "custom-ok-btn",
                                    popup: "custom-swal-popup",
                                },
                                buttonsStyling: false,
                            });
                        });
                });
            }
        });
    });
}


["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, alertConfirm);
});