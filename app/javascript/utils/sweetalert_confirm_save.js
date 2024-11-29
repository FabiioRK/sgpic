import { applyMasks } from "./masks";
import { initializeAddressAutocomplete } from "./fetchAddress";
import Swal from "sweetalert2";
window.Swal = Swal;

function confirmAction(message, iconColor, onConfirm, onCancel) {
    Swal.fire({
        title: "Confirmação necessária",
        text: message,
        icon: "question",
        iconColor: iconColor,
        showCancelButton: true,
        confirmButtonText: "Salvar",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            popup: "custom-swal-popup",
            confirmButton: "custom-confirm-btn",
            cancelButton: "custom-cancel-btn",
        },
        buttonsStyling: false,
        willClose: () => {
            if (onCancel) onCancel();
        },
    }).then((result) => {
        if (result.isConfirmed) {
            onConfirm();
        }
    });
}

function alertConfirmSave() {
    document.addEventListener("submit", (event) => {
        const form = event.target;

        if (form && form.classList.contains("confirm-save")) {
            event.preventDefault();

            const submitButton = event.submitter;
            const message = submitButton.dataset.sweetConfirm || "Deseja realmente salvar este formulário?";
            const iconColor = submitButton.dataset.iconColor || "#28a745";

            const allButtons = form.querySelectorAll("input[type='submit'], button[type='submit']");
            allButtons.forEach((button) => {
                button.disabled = true;
            });

            confirmAction(
                message,
                iconColor,
                () => {
                    const formData = new FormData(form);
                    if (submitButton.name) {
                        formData.append(submitButton.name, submitButton.value || "1");
                    }

                    fetch(form.action, {
                        method: form.method.toUpperCase(),
                        body: formData,
                        headers: {
                            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                        },
                    })
                        .then((response) => {
                            if (response.ok && response.headers.get("content-type")?.includes("application/json")) {
                                return response.json();
                            } else if (response.status === 422) {
                                return response.text().then((html) => {
                                    throw { validationHTML: html };
                                });
                            } else {
                                throw new Error("Erro inesperado.");
                            }
                        })
                        .then((data) => {
                            if (data.success) {
                                Swal.fire({
                                    title: "Sucesso!",
                                    text: data.message,
                                    icon: "success",
                                    customClass: {
                                        popup: "custom-swal-popup",
                                        confirmButton: "custom-ok-btn",
                                    },
                                    buttonsStyling: false,
                                }).then(() => {
                                    Turbo.visit(data.redirect_url);
                                });
                            } else {
                                throw new Error("Resposta inesperada do servidor.");
                            }
                        })
                        .catch((error) => {
                            if (error.validationHTML) {
                                const formContainer = document.querySelector(".form-container");
                                formContainer.innerHTML = error.validationHTML;

                                initializeFormFeatures();

                                Swal.fire({
                                    title: "Erro de validação",
                                    text: "Por favor, corrija os erros do formulário.",
                                    icon: "error",
                                    customClass: {
                                        popup: "custom-swal-popup",
                                        confirmButton: "custom-ok-btn",
                                    },
                                    buttonsStyling: false,
                                });
                            } else {
                                Swal.fire({
                                    title: "Erro!",
                                    text: error.message || "Algo deu errado ao processar sua solicitação.",
                                    icon: "error",
                                    customClass: {
                                        popup: "custom-swal-popup",
                                        confirmButton: "custom-ok-btn",
                                    },
                                    buttonsStyling: false,
                                });
                            }
                        })
                        .finally(() => {
                            allButtons.forEach((button) => {
                                button.disabled = false;
                            });
                        });
                },
                () => {
                    allButtons.forEach((button) => {
                        button.disabled = false;
                    });
                }
            );
        }
    });
}


["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, alertConfirmSave);
});


function initializeFormFeatures() {
    initializeAddressAutocomplete();
    applyMasks();
}
