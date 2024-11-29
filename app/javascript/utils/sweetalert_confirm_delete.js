import Swal from "sweetalert2";
window.Swal = Swal;

function confirmAction(message, onConfirm) {
    Swal.fire({
        title: "Confirmação necessária",
        text: message,
        icon: "warning",
        iconColor: "#dc3545",
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

function alertConfirmDelete() {
    document.querySelectorAll("[data-sweet-confirm]").forEach((element) => {
        element.addEventListener("click", (event) => {
            if (element.classList.contains("delete-post")) {
                const message = element.dataset.sweetConfirm;
                const url = element.href;
                const method = "delete";

                event.preventDefault();
                event.stopPropagation();

                confirmAction(message, () => {
                    fetch(url, {
                        method: method.toUpperCase(),
                        headers: {
                            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                            "Content-Type": "application/json",
                            "Accept": "application/json",
                        },
                    })
                        .then((response) => {
                            if (response.headers.get("content-type")?.includes("application/json")) {
                                return response.json().then((data) => {
                                    return { data, status: response.status };
                                });
                            } else {
                                throw new Error(`Resposta inválida do servidor: ${response.status} ${response.statusText}`);
                            }
                        })
                        .then(({ data, status }) => {
                            if (status === 200 && data.success) {
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
                                    Turbo.visit(data.redirect_url);
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
                                });
                            }
                        })
                        .catch((error) => {
                            Swal.fire({
                                title: "Erro!",
                                text: error.message || "Algo deu errado ao processar sua solicitação.",
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
    document.addEventListener(event, alertConfirmDelete);
});
