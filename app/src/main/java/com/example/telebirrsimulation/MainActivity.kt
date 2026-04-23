package com.example.telebirrsimulation

import android.content.Context
import android.graphics.*
import android.graphics.pdf.PdfDocument
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import java.io.File
import java.io.FileOutputStream
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {

    private lateinit var flipper: ViewFlipper
    private var currentAmount = ""
    private var currentReceiver = ""
    private var currentID = ""
    private var currentTime = ""
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        flipper = findViewById(R.id.viewFlipper)

        // Step 1 to Step 2 (Send to Confirmation)
        findViewById<Button>(R.id.btnSend).setOnClickListener {
            currentReceiver = findViewById<EditText>(R.id.etReceiver).text.toString().trim()
            currentAmount = findViewById<EditText>(R.id.etAmount).text.toString().trim()
            
            if (validateInput()) {
                showConfirmationScreen()
            }
        }

        // Step 2: Cancel button
        findViewById<Button>(R.id.btnCancel).setOnClickListener {
            flipper.displayedChild = 0 // Back to send screen
        }

        // Step 2 to Step 3 (Confirmation to PIN)
        findViewById<Button>(R.id.btnConfirm).setOnClickListener {
            flipper.displayedChild = 2 // Go to PIN screen
        }

        // Step 3 to Step 4 (PIN to Processing)
        findViewById<Button>(R.id.btnConfirmPin).setOnClickListener {
            val pin = findViewById<EditText>(R.id.etPin).text.toString()
            if (pin.length == 4) {
                showProcessingScreen()
            } else {
                Toast.makeText(this, "Please enter 4-digit PIN", Toast.LENGTH_SHORT).show()
            }
        }

        // Step 5: Done button
        findViewById<Button>(R.id.btnDone).setOnClickListener {
            resetToStart()
        }

        // Step 5: Download receipt
        findViewById<TextView>(R.id.btnDownload).setOnClickListener {
            createPdfReceipt()
        }
    }

    private fun validateInput(): Boolean {
        return when {
            currentReceiver.isEmpty() -> {
                Toast.makeText(this, "Please enter receiver name", Toast.LENGTH_SHORT).show()
                false
            }
            currentAmount.isEmpty() -> {
                Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
                false
            }
            currentAmount.toDoubleOrNull() == null || currentAmount.toDouble() <= 0 -> {
                Toast.makeText(this, "Please enter valid amount", Toast.LENGTH_SHORT).show()
                false
            }
            else -> true
        }
    }

    private fun showConfirmationScreen() {
        // Format amount with comma separator and 2 decimal places
        val formattedAmount = formatAmount(currentAmount)
        
        findViewById<TextView>(R.id.tvConfirmAmount).text = "Send $formattedAmount ETB"
        findViewById<TextView>(R.id.tvConfirmReceiver).text = "to: ${currentReceiver.uppercase()}"
        
        flipper.displayedChild = 1 // Go to confirmation screen
    }

    private fun showProcessingScreen() {
        flipper.displayedChild = 3 // Go to processing screen
        
        val processingText = findViewById<TextView>(R.id.tvProcessingText)
        
        // Simulate processing with different messages
        processingText.text = "Sending..."
        handler.postDelayed({
            processingText.text = "Processing..."
        }, 1000)
        
        handler.postDelayed({
            processingText.text = "Finalizing..."
        }, 1500)
        
        handler.postDelayed({
            showSuccessScreen()
        }, 2000)
    }

    private fun showSuccessScreen() {
        // Generate transaction data
        currentID = generateTransactionID()
        currentTime = SimpleDateFormat("yyyy/MM/dd HH:mm:ss", Locale.getDefault()).format(Date())
        
        // Format amount display
        val formattedAmount = formatAmount(currentAmount)
        
        // Update success screen
        findViewById<TextView>(R.id.tvDispAmount).text = "-$formattedAmount ETB"
        findViewById<TextView>(R.id.tvDispRec).text = currentReceiver.uppercase()
        findViewById<TextView>(R.id.tvDispTime).text = currentTime
        findViewById<TextView>(R.id.tvDispID).text = currentID
        
        flipper.displayedChild = 4 // Go to success screen
    }

    private fun resetToStart() {
        // Clear input fields
        findViewById<EditText>(R.id.etReceiver).text.clear()
        findViewById<EditText>(R.id.etAmount).text.clear()
        findViewById<EditText>(R.id.etPin).text.clear()
        
        // Reset to first screen
        flipper.displayedChild = 0
    }

    private fun generateTransactionID(): String {
        val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return (1..10).map { chars.random() }.joinToString("")
    }

    private fun formatAmount(amount: String): String {
        return try {
            val decimalFormat = DecimalFormat("#,##0.00")
            decimalFormat.format(amount.toDouble())
        } catch (e: NumberFormatException) {
            amount
        }
    }

    private fun createPdfReceipt() {
        try {
            val pdf = PdfDocument()
            val pageInfo = PdfDocument.PageInfo.Builder(300, 600, 1).create()
            val page = pdf.startPage(pageInfo)
            val canvas = page.canvas
            
            // Paint objects for different text styles
            val titlePaint = Paint().apply {
                color = Color.BLACK
                textSize = 14f
                isFakeBoldText = true
                textAlign = Paint.Align.CENTER
            }
            
            val normalPaint = Paint().apply {
                color = Color.BLACK
                textSize = 10f
            }
            
            val boldPaint = Paint().apply {
                color = Color.BLACK
                textSize = 10f
                isFakeBoldText = true
            }
            
            val headerPaint = Paint().apply {
                color = Color.GRAY
                textSize = 8f
            }
            
            var yPosition = 40f
            
            // Header
            canvas.drawText("Digital Telecom Payment System (Simulation)", 150f, yPosition, titlePaint)
            yPosition += 30f
            
            canvas.drawText("===========================================", 150f, yPosition, headerPaint)
            yPosition += 25f
            
            // Transaction Details
            canvas.drawText("TRANSACTION RECEIPT", 150f, yPosition, titlePaint)
            yPosition += 30f
            
            // Body Details
            val details = listOf(
                "Payer Name:" to "Demo User",
                "Receiver Name:" to currentReceiver.uppercase(),
                "Transaction Number:" to currentID,
                "Transaction Status:" to "Completed",
                "Transaction Time:" to currentTime,
                "Payment Channel:" to "Mobile App"
            )
            
            details.forEach { (label, value) ->
                canvas.drawText(label, 20f, yPosition, normalPaint)
                canvas.drawText(value, 280f, yPosition, boldPaint)
                yPosition += 20f
            }
            
            yPosition += 15f
            canvas.drawText("-------------------------------------------", 150f, yPosition, headerPaint)
            yPosition += 20f
            
            // Financial Section
            canvas.drawText("FINANCIAL DETAILS", 150f, yPosition, titlePaint)
            yPosition += 25f
            
            val amountValue = currentAmount.toDoubleOrNull() ?: 0.0
            val serviceFee = 7.83
            val vat = 1.17
            val totalPaid = amountValue + serviceFee + vat
            
            val financialDetails = listOf(
                "Amount:" to "${formatAmount(currentAmount)} ETB",
                "Service Fee:" to "${formatAmount(serviceFee.toString())} ETB",
                "VAT:" to "${formatAmount(vat.toString())} ETB",
                "Total Paid:" to "${formatAmount(totalPaid.toString())} ETB"
            )
            
            financialDetails.forEach { (label, value) ->
                canvas.drawText(label, 20f, yPosition, normalPaint)
                canvas.drawText(value, 280f, yPosition, boldPaint)
                yPosition += 20f
            }
            
            yPosition += 20f
            canvas.drawText("-------------------------------------------", 150f, yPosition, headerPaint)
            yPosition += 20f
            
            // Footer
            val footerPaint = Paint().apply {
                color = Color.BLACK
                textSize = 9f
                textAlign = Paint.Align.CENTER
            }
            
            canvas.drawText("Thank you for using the system", 150f, yPosition, footerPaint)
            yPosition += 15f
            
            // Security Stamp (Simulation Feature)
            val stampPaint = Paint().apply {
                color = Color.parseColor("#3F51B5")
                style = Paint.Style.STROKE
                strokeWidth = 2f
                alpha = 180
            }
            
            val stampTextPaint = Paint().apply {
                color = Color.parseColor("#3F51B5")
                textSize = 8f
                textAlign = Paint.Align.CENTER
                alpha = 180
            }
            
            canvas.save()
            canvas.rotate(-15f, 220f, 450f)
            canvas.drawRect(180f, 430f, 260f, 480f, stampPaint)
            canvas.drawText("OFFICIAL", 220f, 450f, stampTextPaint)
            canvas.drawText("TELEBIRR", 220f, 465f, stampTextPaint)
            canvas.restore()
            
            // Training notice
            val trainingPaint = Paint().apply {
                color = Color.RED
                textSize = 8f
                textAlign = Paint.Align.CENTER
            }
            canvas.drawText("TRAINING PURPOSES ONLY - NO REAL TRANSACTION", 150f, 580f, trainingPaint)

            pdf.finishPage(page)

            // Save PDF
            val fileName = "Receipt_$currentID.pdf"
            val file = File(getExternalFilesDir(null), fileName)
            pdf.writeTo(FileOutputStream(file))
            pdf.close()
            
            Toast.makeText(this, "Receipt saved: ${file.name}", Toast.LENGTH_LONG).show()
            
        } catch (e: Exception) {
            Toast.makeText(this, "Error generating PDF: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }
}
