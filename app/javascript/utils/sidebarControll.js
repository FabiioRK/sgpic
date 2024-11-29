document.addEventListener('turbo:load', function () {
    document.body.addEventListener('click', function (event) {
        const sidebarToggle = event.target.closest('#sidebarToggle');
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.querySelector('.main.with-sidebar');
        const contentOverlay = document.getElementById('contentOverlay'); // Seleciona o overlay

        if (sidebarToggle) {
            const isExpanded = sidebar.classList.toggle('expand');

            if (mainContent) {
                mainContent.classList.toggle('expanded', isExpanded);
            }

            // Atualiza o overlay com base no estado da sidebar
            if (contentOverlay) {
                contentOverlay.classList.toggle('visible', isExpanded);
            }
        }

        // Fecha a sidebar clicando no overlay
        if (event.target === contentOverlay) {
            sidebar.classList.remove('expand');
            mainContent.classList.remove('expanded');
            contentOverlay.classList.remove('visible');
        }
    });
});
