document.addEventListener('DOMContentLoaded', function() {
    // Any custom JavaScript can go here
    console.log('Budget Setter application loaded');
    
    // Example: Confirm before deleting
    const deleteButtons = document.querySelectorAll('.btn-delete');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            if (!confirm('Are you sure you want to delete this item?')) {
                e.preventDefault();
            }
        });
    });
});


