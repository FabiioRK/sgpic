import Swal from "sweetalert2";

function showInfoModal(message, iconColor, callback = null, timer = 2000) {
    Swal.fire({
        title: "Informação",
        text: message,
        icon: "info",
        iconColor: iconColor || "#007bff",
        customClass: {
            popup: "custom-swal-popup",
            confirmButton: "custom-ok-btn",
        },
        buttonsStyling: false,
        showConfirmButton: false,
        timer: timer,
        timerProgressBar: true,
    });

    if (callback) {
        setTimeout(callback, timer);
    }
}

function showErrorModal(message) {
    const formattedMessage = message.replace(/\./g, ".<br>");
    Swal.fire({
        title: "Erro!",
        html: formattedMessage,
        icon: "error",
        iconColor: "#dc3545",
        customClass: {
            popup: "custom-swal-popup",
            confirmButton: "custom-ok-btn",
        },
        buttonsStyling: false,
    });
}

function showLoadingModal(minimumTime = 500) {
    const startTime = Date.now();

    Swal.fire({
        title: "Processando...",
        text: "Por favor, aguarde.",
        allowOutsideClick: false,
        allowEscapeKey: false,
        showConfirmButton: false,
        didOpen: () => {
            Swal.showLoading();
        },
    });
    return new Promise((resolve) => {
        setTimeout(() => {
            const elapsedTime = Date.now() - startTime;
            if (elapsedTime >= minimumTime) {
                resolve();
            } else {
                setTimeout(resolve, minimumTime - elapsedTime);
            }
        }, minimumTime);
    });
}

function closeLoadingModal() {
    Swal.close();
}

function handleInfoModalSubmissions() {
    document.querySelectorAll("[data-info-modal]").forEach((element) => {
        element.addEventListener("click", (event) => {
            const message = element.dataset.infoMessage || "Ação concluída com sucesso!";
            const iconColor = element.dataset.iconColor || "#007bff";
            const redirectUrl = element.dataset.redirectUrl || null;
            const method = element.dataset.method || "post";
            const timer = parseInt(element.dataset.timer) || 2000;

            event.preventDefault();
            event.stopPropagation();

            if (method.toLowerCase() === "delete") {
                showInfoModal(message, iconColor, () => {
                    fetch(element.href, {
                        method: "DELETE",
                        headers: {
                            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                        },
                    })
                        .then((response) => {
                            if (response.ok && redirectUrl) {
                                window.location.href = redirectUrl;
                            }
                        })
                        .catch(() => {
                            showErrorModal("Erro ao executar o logout.");
                        });
                }, timer);
            } else {
                const form = element.closest("form");

                if (form) {
                    const formData = new FormData(form);

                    showLoadingModal(300).then(() => {
                        fetch(form.action, {
                            method: form.method || "post",
                            body: formData,
                            headers: {
                                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                            },
                        })
                            .then((response) => {
                                closeLoadingModal();

                                if (response.ok) {
                                    showInfoModal(message, iconColor, () => {
                                        if (redirectUrl) window.location.href = redirectUrl;
                                    }, timer);
                                } else if (response.status === 422) {
                                    return response.text().then((html) => {
                                        throw { html, message: "Erro ao processar o formulário." };
                                    });
                                } else {
                                    throw new Error("Erro inesperado.");
                                }
                            })
                            .catch((error) => {
                                closeLoadingModal();

                                if (error.html) {
                                    const parser = new DOMParser();
                                    const doc = parser.parseFromString(error.html, "text/html");

                                    const alertElement = doc.querySelector(".alert");
                                    const errorMessages = Array.from(doc.querySelectorAll(".alert ul li")).map((li) => li.textContent);

                                    const formattedMessage = errorMessages.length > 0
                                        ? errorMessages.join("<br>")
                                        : (alertElement?.innerText || "Erro ao processar o formulário.");

                                    showErrorModal(formattedMessage);
                                } else {
                                    showErrorModal(error.message || "Algo deu errado.");
                                }
                            });
                    });
                }
            }
        });
    });
}

["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, handleInfoModalSubmissions);
});
